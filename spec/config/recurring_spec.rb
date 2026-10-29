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
end
