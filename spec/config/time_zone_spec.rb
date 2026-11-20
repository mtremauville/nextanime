require "rails_helper"

RSpec.describe "The time zone of the application" do
  it "is Paris, where the airing times are read" do
    expect(Rails.application.config.time_zone).to eq("Europe/Paris")
    expect(Time.zone.name).to eq("Europe/Paris")
  end

  it "keeps storing the times in UTC" do
    expect(ActiveRecord.default_timezone).to eq(:utc)
  end
end
