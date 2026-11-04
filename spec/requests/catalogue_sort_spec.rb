require "rails_helper"

RSpec.describe "Catalogue sort", type: :request do
  def page_of(response)
    Capybara.string(response.body)
  end

  def titles
    page_of(response).all("[data-role='catalogue-item'] h2").map { |node| node.text.strip }
  end

  def query_of(href)
    Rack::Utils.parse_nested_query(URI.parse(href).query)
  end

  before do
    create(:anime, title_romaji: "Popular", popularity: 100, average_score: 60, start_date: Date.new(2010, 1, 1))
    create(:anime, title_romaji: "Rated", popularity: 50, average_score: 95, start_date: Date.new(2015, 1, 1))
    create(:anime, title_romaji: "Recent", popularity: 10, average_score: 70, start_date: Date.new(2024, 1, 1))
  end

  describe "GET /catalogue" do
    it "ranks by popularity when no sort is asked" do
      get catalogue_path

      expect(titles).to eq(%w[Popular Rated Recent])
    end

    it "ranks by the asked sort" do
      get catalogue_path, params: { sort: "score" }
      expect(titles).to eq(%w[Rated Recent Popular])

      get catalogue_path, params: { sort: "recent" }
      expect(titles).to eq(%w[Recent Rated Popular])

      get catalogue_path, params: { sort: "title" }
      expect(titles).to eq(%w[Popular Rated Recent])
    end

    it "ignores a sort it does not know" do
      get catalogue_path, params: { sort: "banana" }

      expect(titles).to eq(%w[Popular Rated Recent])
    end

    it "ignores a sort that is not a text" do
      get catalogue_path, params: { sort: [ "score" ] }

      expect(titles).to eq(%w[Popular Rated Recent])
    end

    it "ranks by popularity when the match is asked and there is no taste profile" do
      get catalogue_path, params: { sort: "match" }

      expect(titles).to eq(%w[Popular Rated Recent])
    end

    it "sorts the search results too" do
      get catalogue_path, params: { q: "e", sort: "recent" }

      expect(titles).to eq(%w[Recent Rated])
    end
  end

  describe "the sort through the pages" do
    before { create_list(:anime, 12, popularity: 1) }

    it "keeps the asked sort in the address of the next page" do
      get catalogue_path, params: { sort: "score" }
      next_link = page_of(response).first("a[rel='next']")

      expect(query_of(next_link[:href])).to include("page" => "2", "sort" => "score")
    end

    it "keeps it in the load more link" do
      get catalogue_path, params: { sort: "recent" }
      more_link = page_of(response).first("a.na-load-more__button", visible: :all)

      expect(query_of(more_link[:href])).to include("page" => "2", "sort" => "recent")
    end

    it "keeps it when more anime are loaded with a turbo stream" do
      create_list(:anime, 12, popularity: 1)

      get catalogue_path(page: 2, sort: "title"), headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include("sort=title")
    end

    it "does not write a sort in the address when none was asked" do
      get catalogue_path
      next_link = page_of(response).first("a[rel='next']")

      expect(query_of(next_link[:href])).not_to have_key("sort")
    end
  end
end
