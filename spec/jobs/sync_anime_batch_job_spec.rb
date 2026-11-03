require "rails_helper"

RSpec.describe SyncAnimeBatchJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:endpoint) { "https://graphql.anilist.co" }
  let(:payload) { JSON.parse(file_fixture("anilist/top_anime_page.json").read) }
  let(:media) { payload.dig("data", "Page", "media") }
  let(:anilist_ids) { media.map { |item| item.fetch("id") } }

  def stub_anilist(body: payload, status: 200, headers: {})
    stub_request(:post, endpoint).to_return(
      status: status,
      body: body.to_json,
      headers: headers.merge("Content-Type" => "application/json")
    )
  end

  describe "#perform" do
    before { stub_anilist }

    it "asks AniList for the given anime only" do
      described_class.perform_now(anilist_ids)

      expect(WebMock).to have_requested(:post, endpoint).with { |request|
        JSON.parse(request.body).dig("variables", "ids") == anilist_ids
      }
    end

    it "refreshes the anime it already knows" do
      first = media.first
      anime = create(:anime, anilist_id: first.fetch("id"), title_romaji: "Outdated title", synced_at: 3.days.ago)

      freeze_time do
        described_class.perform_now(anilist_ids)

        expect(anime.reload.title_romaji).to eq(first.dig("title", "romaji"))
        expect(anime.synced_at).to be_within(1.second).of(Time.current)
      end
    end

    context "when an anime cannot be saved" do
      before do
        media.first["format"] = "HOLOGRAM"
        stub_anilist
        allow(Rails.logger).to receive(:warn)
      end

      it "skips it and refreshes the others" do
        expect { described_class.perform_now(anilist_ids) }.to change(Anime, :count).by(1)
      end

      it "tells which anime was skipped" do
        described_class.perform_now(anilist_ids)

        expect(Rails.logger).to have_received(:warn)
          .with(/SyncAnimeBatchJob skipped anime #{anilist_ids.first}/)
      end
    end

    context "when AniList cannot be reached" do
      before { stub_request(:post, endpoint).to_timeout }

      it "tries again later" do
        expect { described_class.perform_now(anilist_ids) }
          .to have_enqueued_job(described_class).with(anilist_ids)
      end
    end

    context "when the rate limit is reached" do
      before { stub_anilist(body: {}, status: 429, headers: { "Retry-After" => "30" }) }

      it "tries again after the delay given by AniList" do
        freeze_time do
          expect { described_class.perform_now(anilist_ids) }
            .to have_enqueued_job(described_class).with(anilist_ids).at(30.seconds.from_now)
        end
      end
    end
  end
end
