require "rails_helper"

RSpec.describe Anilist::Client do
  subject(:client) { described_class.new }

  let(:endpoint) { "https://graphql.anilist.co" }
  let(:response_body) { file_fixture("anilist/top_anime_page.json").read }

  before do
    stub_request(:post, endpoint).to_return(
      status: 200,
      body: response_body,
      headers: { "Content-Type" => "application/json" }
    )
  end

  def sent_payload
    payload = nil
    expect(WebMock).to have_requested(:post, endpoint).with { |request| payload = JSON.parse(request.body) }
    payload
  end

  describe "#top_anime" do
    it "posts JSON to the AniList GraphQL endpoint" do
      client.top_anime

      expect(WebMock).to have_requested(:post, endpoint).with(
        headers: { "Content-Type" => "application/json", "Accept" => "application/json" }
      )
    end

    it "asks for anime sorted by popularity" do
      client.top_anime

      expect(sent_payload["query"]).to include("type: ANIME", "sort: POPULARITY_DESC")
    end

    it "asks for the first page of 50 anime by default" do
      client.top_anime

      expect(sent_payload["variables"]).to eq("page" => 1, "perPage" => 50)
    end

    it "asks for the requested page and size" do
      client.top_anime(page: 3, per_page: 25)

      expect(sent_payload["variables"]).to eq("page" => 3, "perPage" => 25)
    end

    it "asks for everything the import needs" do
      client.top_anime

      expect(sent_payload["query"]).to include(
        "title", "format", "status", "season", "seasonYear", "episodes", "duration",
        "averageScore", "popularity", "description", "coverImage", "nextAiringEpisode",
        "genres", "tags", "studios"
      )
    end

    describe "the returned page" do
      subject(:page) { client.top_anime }

      it "is numbered like the AniList page" do
        expect(page.number).to eq(2)
      end

      it "tells that another page follows" do
        expect(page.has_next_page).to be(true)
      end

      it "holds the raw media of the page" do
        expect(page.media.map { |media| media["id"] }).to eq([ 1, 154587 ])
      end

      it "keeps the nested data of each media" do
        expect(page.media.first.dig("studios", "edges", 0, "node", "name")).to eq("Sunrise")
      end
    end
  end
end
