require "rails_helper"
require "fugit"

RSpec.describe "config/recurring.yml" do
  let(:task) { Rails.application.config_for(:recurring, env: "production").fetch(:sync_airing_anime) }

  it "synchronizes the airing anime in production" do
    expect(task[:class]).to eq("SyncAiringAnimeJob")
  end

  it "names a job that exists" do
    expect(task[:class].constantize).to be < ApplicationJob
  end

  it "runs every six hours" do
    cron = Fugit.parse_cron(task[:schedule])
    first = cron.next_time(Time.utc(2026, 1, 1))
    second = cron.next_time(first)

    expect(second.to_i - first.to_i).to eq(6.hours.to_i)
  end
  describe "the synchronization of the streaming availabilities" do
    let(:task) { Rails.application.config_for(:recurring, env: "production").fetch(:sync_streaming_availabilities) }

    it "runs the job that enqueues the batches" do
      expect(task[:class]).to eq("SyncStreamingAvailabilitiesJob")
    end

    it "names a job that exists" do
      expect(task[:class].constantize).to be < ApplicationJob
    end

    it "runs once a week" do
      cron = Fugit.parse_cron(task[:schedule])
      first = cron.next_time(Time.utc(2026, 1, 1))
      second = cron.next_time(first)

      expect(second.to_i - first.to_i).to eq(1.week.to_i)
    end

    it "does not start at the top of the hour, when the other jobs are busy" do
      expect(Fugit.parse_cron(task[:schedule]).minutes).not_to include(0)
    end
  end
end
