require "rails_helper"

RSpec.describe "Catalogue filters sheet", type: :request do
  def page_of(response)
    Capybara.string(response.body)
  end

  def sheet
    page_of(response).find("dialog#filters-sheet", visible: :all)
  end

  describe "GET /catalogue" do
    it "offers a button that opens the filters, for phones only" do
      get catalogue_path

      expect(page_of(response)).to have_css(".d-md-none button.na-filters-trigger[aria-controls='filters-sheet']")
    end

    it "tells how many filters are active on the button" do
      get catalogue_path, params: { formats: %w[movie], year_from: "2000" }

      expect(page_of(response)).to have_button("Filtres (2)")
    end

    it "has no count on the button when no filter is active" do
      get catalogue_path

      expect(page_of(response)).to have_button("Filtres", exact: true)
    end

    it "holds the filters in a dialog named after them" do
      get catalogue_path

      expect(sheet[:"aria-labelledby"]).to eq("filters-sheet-title")
      expect(sheet).to have_css(".na-filters--sheet", visible: :all)
      expect(page_of(response)).to have_css("#filters-sheet-title", text: "Filtres", visible: :all)
    end

    it "has the filters already chosen checked in the sheet" do
      get catalogue_path, params: { formats: %w[movie] }

      expect(sheet).to have_css("input#sheet-filter-formats-movie[checked]", visible: :all)
    end

    it "carries the search and the sort in the sheet" do
      get catalogue_path, params: { q: "mon", sort: "recent" }

      expect(sheet).to have_css("input[type='hidden'][name='q'][value='mon']", visible: :all)
      expect(sheet).to have_css("input[type='hidden'][name='sort'][value='recent']", visible: :all)
    end

    it "sends the sheet to the catalogue with a GET" do
      get catalogue_path

      expect(sheet).to have_css("form[action='#{catalogue_path}'][method='get']", visible: :all)
    end

    it "has no id twice, although the filters are in the column and in the sheet" do
      create(:genre, name: "Action")

      get catalogue_path, params: { formats: %w[movie] }

      ids = page_of(response).all("[id]", visible: :all).map { |node| node[:id] }
      expect(ids.tally.select { |_id, times| times > 1 }).to eq({})
    end
  end
end
