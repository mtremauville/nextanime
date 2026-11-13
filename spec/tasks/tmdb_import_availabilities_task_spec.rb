require "rails_helper"
require "rake"

RSpec.describe "tmdb:import_availabilities" do
  let(:task) { Rake::Task["tmdb:import_availabilities"] }
  let(:sync) { instance_double(Tmdb::AvailabilitySync, call: report) }
  let(:report) { Tmdb::AvailabilitySync::Report.new(matched: [], unmatched: [], failed: []) }

  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?("tmdb:import_availabilities")
  end

  before do
    task.reenable
    allow(Tmdb::AvailabilitySync).to receive(:new).and_return(sync)
    allow(Anime).to receive(:most_popular).and_call_original
    allow($stdout).to receive(:puts)
  end

  it "takes the 100 most popular anime by default" do
    task.invoke

    expect(Anime).to have_received(:most_popular).with(100)
  end

  it "accepts another limit" do
    task.invoke("25")

    expect(Anime).to have_received(:most_popular).with(25)
  end

  it "imports the availabilities of the most popular anime" do
    popular = create(:anime, popularity: 900)
    create(:anime, popularity: 10)

    task.invoke("1")

    expect(sync).to have_received(:call) { |animes| expect(animes.to_a).to eq([ popular ]) }
  end

  it "prints the report" do
    task.invoke("1")

    expect($stdout).to have_received(:puts).with(report.to_s)
  end

  it "refuses a limit that is not a number" do
    expect { task.invoke("many") }.to raise_error(ArgumentError)
  end
end
