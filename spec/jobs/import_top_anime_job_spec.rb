require "rails_helper"

RSpec.describe ImportTopAnimeJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:endpoint) { "https://graphql.anilist.co" }
  let(:payload) { JSON.parse(file_fixture("anilist/top_anime_page.json").read) }

  def stub_anilist(body: payload, status: 200, headers: {})
    stub_request(:post, endpoint).to_return(
      status: status,
      body: body.to_json,
      headers: headers.merge("Content-Type" => "application/json")
    )
  end

  def without_next_page
    payload.deep_merge("data" => { "Page" => { "pageInfo" => { "hasNextPage" => false } } })
  end

  describe "#perform" do
    before { stub_anilist }

    it "imports every anime of the page" do
      expect { described_class.perform_now(page: 1, remaining: 500) }.to change(Anime, :count).by(2)
    end

    it "asks AniList for the requested page" do
      described_class.perform_now(page: 3, remaining: 500)

      expect(WebMock).to have_requested(:post, endpoint).with { |request|
        JSON.parse(request.body).dig("variables", "page") == 3
      }
    end

    it "starts at the first page and aims at 500 anime by default" do
      freeze_time do
        expect { described_class.perform_now }
          .to have_enqueued_job(described_class).with(page: 2, remaining: 498)
      end
    end

    it "enqueues the next page after a short pause" do
      freeze_time do
        expect { described_class.perform_now(page: 1, remaining: 500) }
          .to have_enqueued_job(described_class)
          .with(page: 2, remaining: 498)
          .at(described_class::PAUSE_BETWEEN_PAGES.from_now)
      end
    end

    context "when this is the last page" do
      before { stub_anilist(body: without_next_page) }

      it "enqueues nothing more" do
        expect { described_class.perform_now(page: 9, remaining: 500) }.not_to have_enqueued_job(described_class)
      end
    end

    context "when the limit is reached with this page" do
      it "enqueues nothing more" do
        expect { described_class.perform_now(page: 1, remaining: 2) }.not_to have_enqueued_job(described_class)
      end
    end

    context "when fewer anime are wanted than the page holds" do
      it "imports only what remains" do
        expect { described_class.perform_now(page: 1, remaining: 1) }.to change(Anime, :count).by(1)
        expect(Anime.pick(:anilist_id)).to eq(1)
      end
    end

    context "when an anime cannot be saved" do
      before do
        payload["data"]["Page"]["media"].first["format"] = "HOLOGRAM"
        stub_anilist
        allow(Rails.logger).to receive(:warn)
      end

      it "skips it and imports the others" do
        expect { described_class.perform_now(page: 1, remaining: 500) }.to change(Anime, :count).by(1)
        expect(Anime.pick(:anilist_id)).to eq(154_587)
      end

      it "tells which anime was skipped" do
        described_class.perform_now(page: 1, remaining: 500)

        expect(Rails.logger).to have_received(:warn).with(/skipped anime 1:/)
      end

      it "still goes on with the next page" do
        expect { described_class.perform_now(page: 1, remaining: 500) }
          .to have_enqueued_job(described_class).with(page: 2, remaining: 498)
      end
    end

    context "when the rate limit is reached" do
      it "tries the same page again after the delay given by AniList" do
        stub_anilist(body: {}, status: 429, headers: { "Retry-After" => "30" })

        freeze_time do
          expect { described_class.perform_now(page: 4, remaining: 120) }
            .to have_enqueued_job(described_class).with(page: 4, remaining: 120).at(30.seconds.from_now)
        end
      end

      it "waits a default delay when AniList does not say" do
        stub_anilist(body: {}, status: 429)

        freeze_time do
          expect { described_class.perform_now(page: 4, remaining: 120) }
            .to have_enqueued_job(described_class)
            .with(page: 4, remaining: 120)
            .at(described_class::DEFAULT_RATE_LIMIT_WAIT.from_now)
        end
      end

      it "imports nothing meanwhile" do
        stub_anilist(body: {}, status: 429)

        expect { described_class.perform_now(page: 1, remaining: 500) }.not_to change(Anime, :count)
      end

      it "gives up after too many attempts" do
        stub_anilist(body: {}, status: 429)
        job = described_class.new(page: 1, remaining: 500)
        job.executions = described_class::MAX_RATE_LIMIT_RETRIES

        expect { job.perform_now }.to raise_error(Anilist::RateLimitedError)
      end
    end

    context "when AniList cannot be reached" do
      it "tries again later" do
        stub_request(:post, endpoint).to_timeout

        expect { described_class.perform_now(page: 2, remaining: 400) }
          .to have_enqueued_job(described_class).with(page: 2, remaining: 400)
      end
    end

    context "when AniList fails" do
      it "lets the job fail instead of hiding an incomplete import" do
        stub_request(:post, endpoint).to_return(status: 500)

        expect { described_class.perform_now(page: 1, remaining: 500) }.to raise_error(Anilist::ResponseError)
      end
    end
  end
end
