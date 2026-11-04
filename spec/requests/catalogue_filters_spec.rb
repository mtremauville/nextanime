require "rails_helper"

RSpec.describe "Catalogue filters", type: :request do
  def page_of(response)
    Capybara.string(response.body)
  end

  def titles
    page_of(response).all("[data-role='catalogue-item'] h2").map { |node| node.text.strip }
  end

  def query_of(href)
    Rack::Utils.parse_nested_query(URI.parse(href).query)
  end

  describe "GET /catalogue with filters" do
    it "lists only the anime of the asked format" do
      create(:anime, title_romaji: "Series", format: :tv)
      create(:anime, title_romaji: "Film", format: :movie)

      get catalogue_path, params: { formats: %w[movie] }

      expect(titles).to eq(%w[Film])
    end

    it "lists only the anime of every asked genre" do
      action = create(:genre, name: "Action")
      comedy = create(:genre, name: "Comedy")
      create(:anime, title_romaji: "Both", genres: [ action, comedy ])
      create(:anime, title_romaji: "Only action", genres: [ action ])

      get catalogue_path, params: { genre_ids: [ action.id, comedy.id ] }

      expect(titles).to eq(%w[Both])
    end

    it "combines the filters with the search" do
      create(:anime, title_romaji: "Monster", format: :tv, season: :fall)
      create(:anime, title_romaji: "Monster film", format: :movie, season: :fall)
      create(:anime, title_romaji: "Other", format: :tv, season: :fall)

      get catalogue_path, params: { q: "monster", formats: %w[tv], season: "fall" }

      expect(titles).to eq(%w[Monster])
    end

    it "filters by status and by years" do
      create(:anime, title_romaji: "Old and done", airing_status: :finished, season_year: 1995)
      create(:anime, title_romaji: "Recent and done", airing_status: :finished, season_year: 2020)
      create(:anime, title_romaji: "Recent and ongoing", airing_status: :releasing, season_year: 2020)

      get catalogue_path, params: { statuses: %w[finished], year_from: "2000", year_to: "2026" }

      expect(titles).to eq([ "Recent and done" ])
    end

    it "ignores values it does not know" do
      create(:anime, title_romaji: "Alpha")
      create(:anime, title_romaji: "Beta")

      get catalogue_path, params: { formats: %w[banana], season: "banana", year_from: "abc", genre_ids: %w[abc] }

      expect(titles).to match_array(%w[Alpha Beta])
    end

    it "ignores filters that are not lists or texts" do
      create(:anime, title_romaji: "Alpha")

      get catalogue_path, params: { formats: { "a" => "tv" }, season: [ "fall" ] }

      expect(titles).to eq(%w[Alpha])
    end
  end

  describe "the filters through the pages" do
    before { create_list(:anime, 13, format: :tv) }

    it "keeps them in the address of the next page" do
      create(:anime, format: :movie)

      get catalogue_path, params: { formats: %w[tv], q: "" }
      next_link = page_of(response).first("a[rel='next']")

      expect(query_of(next_link[:href])).to include("page" => "2", "formats" => %w[tv])
    end

    it "keeps them in the load more link" do
      get catalogue_path, params: { formats: %w[tv], season: "" }
      more_link = page_of(response).first("a.na-load-more__button", visible: :all)

      expect(query_of(more_link[:href])).to include("page" => "2", "formats" => %w[tv])
    end

    it "keeps them in the load more link of a turbo stream" do
      create_list(:anime, 12, format: :tv)

      get catalogue_path(page: 2, formats: %w[tv]), headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("formats%5B%5D=tv")
    end

    it "does not count the anime that are filtered out" do
      create_list(:anime, 5, format: :movie)

      get catalogue_path, params: { formats: %w[movie] }

      expect(titles.size).to eq(5)
      expect(page_of(response)).to have_no_css("a[rel='next']")
    end
  end
end
