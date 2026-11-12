require "rails_helper"

RSpec.describe ImportAiringAnimeJob, type: :job do
  include ActiveJob::TestHelper

  let(:endpoint) { "https://graphql.anilist.co" }
  let(:payload) { JSON.parse(file_fixture("anilist/top_anime_page.json").read) }

  before do
    stub_request(:post, endpoint).to_return(
      status: 200,
      body: payload.to_json,
      headers: { "Content-Type" => "application/json" }
    )
  end

  describe "#perform" do
    it "asks AniList for the anime that are airing now" do
      described_class.perform_now(page: 1, remaining: 500)

      expect(WebMock).to have_requested(:post, endpoint).with { |request|
        JSON.parse(request.body)["query"].include?("status: RELEASING")
      }
    end

    it "imports every anime of the page" do
      expect { described_class.perform_now(page: 1, remaining: 500) }.to change(Anime, :count).by(2)
    end

    it "starts at the first page, aims at its own limit and goes on with itself" do
      expect { described_class.perform_now }
        .to have_enqueued_job(described_class)
        .with(page: 2, remaining: described_class::AIRING_ANIME_LIMIT - 2)
    end

    it "is retried and paced like the import of the most popular anime" do
      expect(described_class.superclass).to eq(ImportAnimePagesJob)
    end
  end
end
