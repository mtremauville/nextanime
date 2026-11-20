require "rails_helper"

RSpec.describe SyncAiringAnimeJob, type: :job do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  describe "#perform" do
    it "enqueues the airing and the upcoming anime in one batch" do
      airing = create(:anime, airing_status: :releasing)
      upcoming = create(:anime, airing_status: :not_yet_released)

      expect { described_class.perform_now }
        .to have_enqueued_job(SyncAnimeBatchJob)
        .with(contain_exactly(airing.anilist_id, upcoming.anilist_id))
    end

    it "ignores the anime that are over" do
      create(:anime, airing_status: :finished)

      expect { described_class.perform_now }.not_to have_enqueued_job(SyncAnimeBatchJob)
    end

    it "splits the anime in batches of 50, one pause apart" do
      create_list(:anime, 51, airing_status: :releasing)

      freeze_time do
        described_class.perform_now

        expect(SyncAnimeBatchJob).to have_been_enqueued.with(satisfy { |ids| ids.size == 50 }).exactly(:once)
        expect(SyncAnimeBatchJob).to have_been_enqueued
          .with(satisfy { |ids| ids.size == 1 }).at(2.seconds.from_now).exactly(:once)
      end
    end
  end
end
