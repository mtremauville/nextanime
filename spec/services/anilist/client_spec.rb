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
        "genres", "tags", "studios",
        "bannerImage", "startDate", "endDate", "category", "isAnimationStudio"
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

    context "when the rate limit is reached" do
      before do
        stub_request(:post, endpoint).to_return(status: 429, headers: { "Retry-After" => "60" })
      end

      it "raises a rate limit error that tells when to retry" do
        expect { client.top_anime }.to raise_error(Anilist::RateLimitedError) do |error|
          expect(error.retry_after).to eq(60)
          expect(error.status).to eq(429)
          expect(error.message).to include("rate limit")
        end
      end

      it "is a response error" do
        expect { client.top_anime }.to raise_error(Anilist::ResponseError)
      end

      it "has no delay to wait when AniList does not say" do
        stub_request(:post, endpoint).to_return(status: 429)

        expect { client.top_anime }.to raise_error(Anilist::RateLimitedError) do |error|
          expect(error.retry_after).to be_nil
        end
      end
    end

    context "when AniList answers with an HTTP error" do
      before { stub_request(:post, endpoint).to_return(status: 500, body: "Internal Server Error") }

      it "raises a response error carrying the status" do
        expect { client.top_anime }.to raise_error(Anilist::ResponseError, /HTTP 500/) do |error|
          expect(error.status).to eq(500)
        end
      end
    end

    context "when the response is not JSON" do
      before { stub_request(:post, endpoint).to_return(status: 200, body: "<html>Maintenance</html>") }

      it "raises a response error" do
        expect { client.top_anime }.to raise_error(Anilist::ResponseError, /unreadable/) do |error|
          expect(error.status).to eq(200)
        end
      end
    end

    [ "{}", '{"data":{}}' ].each do |body|
      context "when the response is missing its data (#{body})" do
        before { stub_request(:post, endpoint).to_return(status: 200, body: body) }

        it "raises a response error" do
          expect { client.top_anime }.to raise_error(Anilist::ResponseError, /unexpected/)
        end
      end
    end

    context "when the body holds GraphQL errors" do
      before do
        stub_request(:post, endpoint).to_return(
          status: 200,
          body: { errors: [ { message: "Max query complexity exceeded", status: 400 } ], data: nil }.to_json
        )
      end

      it "raises a GraphQL error with the messages and the details" do
        expect { client.top_anime }.to raise_error(Anilist::GraphqlError, /Max query complexity exceeded/) do |error|
          expect(error.errors.first["status"]).to eq(400)
        end
      end
    end

    context "when AniList cannot be reached" do
      {
        "times out" => :timeout,
        "refuses the connection" => Errno::ECONNREFUSED,
        "cannot be resolved" => SocketError
      }.each do |description, failure|
        it "raises a connection error when AniList #{description}" do
          request = stub_request(:post, endpoint)
          failure == :timeout ? request.to_timeout : request.to_raise(failure)

          expect { client.top_anime }.to raise_error(Anilist::ConnectionError, /Could not reach AniList/)
        end
      end
    end

    it "lets the caller rescue every failure with a single class" do
      stub_request(:post, endpoint).to_return(status: 503)

      expect { client.top_anime }.to raise_error(Anilist::Error)
    end
  end
end
