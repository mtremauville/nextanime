require "rails_helper"

RSpec.describe SyncStreamingAvailabilitiesBatchJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  let(:sync) { instance_double(Tmdb::AvailabilitySync, call: report) }
  let(:animes) { create_list(:anime, 2) }
  let(:report) { build_report(matched: animes) }

  def build_report(matched: [], unmatched: [], failed: [])
    Tmdb::AvailabilitySync::Report.new(matched: matched, unmatched: unmatched, failed: failed)
  end

  def failure(anime, error)
    Tmdb::AvailabilitySync::Failure.new(anime: anime, error: error)
  end

  before do
    allow(Tmdb::AvailabilitySync).to receive(:new).and_return(sync)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:warn)
  end

  describe "#perform" do
    it "synchronizes the given anime only" do
      create(:anime)

      described_class.perform_now(animes.map(&:id))

      expect(sync).to have_received(:call).with(contain_exactly(*animes))
    end

    it "tells how the synchronization went" do
      described_class.perform_now(animes.map(&:id))

      expect(Rails.logger).to have_received(:info).with(/SyncStreamingAvailabilitiesBatchJob: 2 anime processed/)
    end

    it "does not try again when everything went well" do
      expect { described_class.perform_now(animes.map(&:id)) }.not_to have_enqueued_job(described_class)
    end

    context "when TMDB cannot be reached for one anime" do
      let(:report) do
        build_report(matched: [ animes.first ], failed: [ failure(animes.last, Tmdb::ConnectionError.new("timeout")) ])
      end

      it "tries again later for this anime only" do
        freeze_time do
          expect { described_class.perform_now(animes.map(&:id)) }
            .to have_enqueued_job(described_class).with([ animes.last.id ], 2).at(60.seconds.from_now)
        end
      end
    end

    context "when the rate limit is reached" do
      let(:report) do
        build_report(failed: [
          failure(animes.first, Tmdb::RateLimitedError.new(retry_after: 30)),
          failure(animes.last, Tmdb::RateLimitedError.new(retry_after: 45))
        ])
      end

      it "waits for the longest delay given by TMDB" do
        freeze_time do
          expect { described_class.perform_now(animes.map(&:id)) }
            .to have_enqueued_job(described_class).with(animes.map(&:id), 2).at(45.seconds.from_now)
        end
      end
    end

    context "when TMDB refuses a request for good" do
      let(:report) do
        build_report(failed: [ failure(animes.first, Tmdb::ResponseError.new("TMDB answered 401", status: 401)) ])
      end

      it "does not try again and tells which anime was skipped" do
        expect { described_class.perform_now(animes.map(&:id)) }.not_to have_enqueued_job(described_class)
        expect(Rails.logger).to have_received(:warn).with(/skipped anime #{animes.first.id}/)
      end
    end

    context "when the attempts are used up" do
      let(:report) do
        build_report(failed: [ failure(animes.first, Tmdb::ConnectionError.new("timeout")) ])
      end

      it "gives up and tells which anime was left" do
        expect { described_class.perform_now(animes.map(&:id), described_class::MAX_ATTEMPTS) }
          .not_to have_enqueued_job(described_class)
        expect(Rails.logger).to have_received(:warn).with(/gave up on anime #{animes.first.id}/)
      end
    end
  end
end
