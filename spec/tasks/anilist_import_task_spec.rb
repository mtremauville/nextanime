require "rails_helper"
require "rake"

RSpec.describe "anilist:import" do
  include ActiveJob::TestHelper

  let(:task) { Rake::Task["anilist:import"] }

  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?("anilist:import")
  end

  before do
    task.reenable
    allow($stdout).to receive(:puts)
  end

  it "enqueues the import of the 500 most popular anime by default" do
    expect { task.invoke }.to have_enqueued_job(ImportTopAnimeJob).with(page: 1, remaining: 500)
  end

  it "accepts another limit" do
    expect { task.invoke("100") }.to have_enqueued_job(ImportTopAnimeJob).with(page: 1, remaining: 100)
  end

  it "tells what was enqueued" do
    task.invoke("100")

    expect($stdout).to have_received(:puts).with(/top 100 anime/)
  end

  it "refuses a limit that is not a number" do
    expect { task.invoke("many") }.to raise_error(ArgumentError)
  end
end
