require "rails_helper"

RSpec.describe SyncStreamingAvailabilitiesJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  describe "#perform" do
    it "enqueues the whole catalogue in one batch" do
      animes = create_list(:anime, 3)

      expect { described_class.perform_now }
        .to have_enqueued_job(SyncStreamingAvailabilitiesBatchJob)
        .with(contain_exactly(*animes.map(&:id)))
    end

    it "enqueues nothing when the catalogue is empty" do
      expect { described_class.perform_now }.not_to have_enqueued_job(SyncStreamingAvailabilitiesBatchJob)
    end

    it "splits the anime in batches of 25, one pause apart" do
      create_list(:anime, 26)

      freeze_time do
        described_class.perform_now

        expect(SyncStreamingAvailabilitiesBatchJob)
          .to have_been_enqueued.with(satisfy { |ids| ids.size == 25 }).exactly(:once)
        expect(SyncStreamingAvailabilitiesBatchJob)
          .to have_been_enqueued.with(satisfy { |ids| ids.size == 1 }).at(5.seconds.from_now).exactly(:once)
      end
    end
  end
end
