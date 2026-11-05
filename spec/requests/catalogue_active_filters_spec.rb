require "rails_helper"

RSpec.describe "Catalogue active filters", type: :request do
  def page_of(response)
    Capybara.string(response.body)
  end

  def query_of(href)
    Rack::Utils.parse_nested_query(URI.parse(href).query)
  end

  def removal_href(label)
    page_of(response).find_link("Retirer le filtre #{label}")[:href]
  end

  describe "GET /catalogue" do
    it "shows no chip when no filter is active" do
      get catalogue_path

      expect(page_of(response)).to have_no_css(".na-active-filters")
    end

    it "shows one chip for each active filter" do
      action = create(:genre, name: "Action")

      get catalogue_path, params: { genre_ids: [ action.id ], formats: %w[movie] }

      expect(page_of(response)).to have_css(".na-active-filters .na-filter-chip", text: "Action")
      expect(page_of(response)).to have_css(".na-active-filters .na-filter-chip", text: "Film")
    end

    it "links a chip to the catalogue without that filter only" do
      action = create(:genre, name: "Action")

      get catalogue_path, params: { genre_ids: [ action.id ], formats: %w[movie] }

      expect(query_of(removal_href("Action"))).to eq("formats" => [ "movie" ])
    end

    it "keeps the search and the sort when a filter is removed" do
      get catalogue_path, params: { q: "mon", sort: "recent", formats: %w[movie] }

      expect(query_of(removal_href("Film"))).to eq("q" => "mon", "sort" => "recent")
    end

    it "removes both years with one chip" do
      get catalogue_path, params: { year_from: "2000", year_to: "2010" }

      expect(query_of(removal_href("2000–2010"))).to eq({})
    end
  end
end
