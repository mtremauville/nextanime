require "rails_helper"

RSpec.describe Tmdb::Client do
  subject(:client) { described_class.new(token: "test-token") }

  let(:base_url) { "https://api.themoviedb.org/3" }

  def json_response(fixture)
    { status: 200, body: file_fixture("tmdb/#{fixture}").read, headers: { "Content-Type" => "application/json" } }
  end

  shared_examples "a call that handles the TMDB failures" do
    it "raises a connection error when TMDB cannot be reached" do
      stub_request(:get, url).to_timeout

      expect { perform.call }.to raise_error(Tmdb::ConnectionError, /Could not reach TMDB/)
    end

    it "raises a response error with the status of an HTTP failure" do
      stub_request(:get, url).to_return(status: 500)

      expect { perform.call }.to raise_error(Tmdb::ResponseError) { |error| expect(error.status).to eq(500) }
    end

    it "raises a rate limited error with the delay asked by TMDB" do
      stub_request(:get, url).to_return(status: 429, headers: { "Retry-After" => "7" })

      expect { perform.call }.to raise_error(Tmdb::RateLimitedError) { |error| expect(error.retry_after).to eq(7) }
    end

    it "raises a rate limited error without delay when TMDB gives none" do
      stub_request(:get, url).to_return(status: 429)

      expect { perform.call }.to raise_error(Tmdb::RateLimitedError) { |error| expect(error.retry_after).to be_nil }
    end

    it "raises a response error when the answer is not JSON" do
      stub_request(:get, url).to_return(status: 200, body: "<html>oops</html>")

      expect { perform.call }.to raise_error(Tmdb::ResponseError, /unreadable/)
    end

    it "raises a response error when the answer has no results" do
      stub_request(:get, url).to_return(status: 200, body: "{}")

      expect { perform.call }.to raise_error(Tmdb::ResponseError, /unexpected/)
    end
  end

  describe "#search" do
    let(:url) { %r{api\.themoviedb\.org/3/search/} }
    let(:perform) { -> { client.search(media_type: :tv, query: "Frieren") } }

    before do
      stub_request(:get, "#{base_url}/search/tv").with(query: hash_including({})).to_return(json_response("search_tv.json"))
      stub_request(:get, "#{base_url}/search/movie").with(query: hash_including({})).to_return(json_response("search_movie.json"))
    end

    it "searches the series on the tv endpoint with the query" do
      client.search(media_type: :tv, query: "Sousou no Frieren")

      expect(WebMock).to have_requested(:get, "#{base_url}/search/tv").with(query: hash_including("query" => "Sousou no Frieren"))
    end

    it "searches the films on the movie endpoint" do
      client.search(media_type: :movie, query: "Spirited Away")

      expect(WebMock).to have_requested(:get, "#{base_url}/search/movie").with(query: hash_including("query" => "Spirited Away"))
    end

    it "keeps the Japanese characters of a title" do
      client.search(media_type: :tv, query: "葬送のフリーレン")

      expect(WebMock).to have_requested(:get, "#{base_url}/search/tv").with(query: hash_including("query" => "葬送のフリーレン"))
    end

    it "leaves the adult content out" do
      client.search(media_type: :tv, query: "Frieren")

      expect(WebMock).to have_requested(:get, "#{base_url}/search/tv").with(query: hash_including("include_adult" => "false"))
    end

    it "authenticates with the bearer token" do
      client.search(media_type: :tv, query: "Frieren")

      expect(WebMock).to have_requested(:get, "#{base_url}/search/tv")
        .with(query: hash_including({}), headers: { "Authorization" => "Bearer test-token" })
    end

    it "returns the raw results" do
      expect(client.search(media_type: :tv, query: "Frieren").pluck("id")).to eq([ 209_867, 1 ])
    end

    it "refuses a media type that TMDB does not know" do
      expect { client.search(media_type: :game, query: "Frieren") }.to raise_error(ArgumentError, /media type/)
    end

    it_behaves_like "a call that handles the TMDB failures"
  end

  describe "#watch_providers" do
    let(:url) { "#{base_url}/tv/209867/watch/providers" }
    let(:perform) { -> { client.watch_providers(media_type: :tv, tmdb_id: 209_867) } }

    before { stub_request(:get, url).to_return(json_response("watch_providers.json")) }

    it "asks for the providers of the title" do
      client.watch_providers(media_type: :tv, tmdb_id: 209_867)

      expect(WebMock).to have_requested(:get, url).with(headers: { "Authorization" => "Bearer test-token" })
    end

    it "uses the movie endpoint for a film" do
      stub_request(:get, "#{base_url}/movie/129/watch/providers").to_return(json_response("watch_providers.json"))

      client.watch_providers(media_type: :movie, tmdb_id: 129)

      expect(WebMock).to have_requested(:get, "#{base_url}/movie/129/watch/providers")
    end

    it "returns the offers by country" do
      providers = client.watch_providers(media_type: :tv, tmdb_id: 209_867)

      expect(providers.keys).to contain_exactly("FR", "US")
      expect(providers.dig("FR", "flatrate").pluck("provider_name")).to eq(%w[Crunchyroll ADN])
    end

    it_behaves_like "a call that handles the TMDB failures"
  end
end
