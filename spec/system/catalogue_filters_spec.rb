require "rails_helper"

RSpec.describe "Filtering the catalogue", type: :system, js: true do
  before do
    create(:anime, title_romaji: "Series one", format: :tv)
    create(:anime, title_romaji: "Series two", format: :tv)
    create(:anime, title_romaji: "A film", format: :movie)
  end

  def titles
    page.all("[data-role='catalogue-item'] h2").map { |node| node.text.strip }
  end

  context "on a wide screen" do
    before { page.current_window.resize_to(1280, 900) }

    it "narrows the list to the chosen format" do
      visit catalogue_path

      within("aside[aria-label='Filtres']") { check "Film", allow_label_click: true }

      expect(page).to have_css("[data-role='catalogue-item']", count: 1)
      expect(titles).to eq([ "A film" ])
      expect(page).to have_checked_field("Film", visible: :all)
    end

    it "keeps the filters when searching" do
      visit catalogue_path(formats: %w[tv])

      find("form[role='search'] input[name='q']").set("two").send_keys(:enter)

      expect(page).to have_css("[data-role='catalogue-item']", count: 1)
      expect(titles).to eq([ "Series two" ])
      expect(page).to have_checked_field("Série", visible: :all)
    end

    it "keeps the filters from page to page" do
      create_list(:anime, 12, format: :tv)

      visit catalogue_path(formats: %w[tv])
      find("a[rel='next']").click

      expect(page).to have_css("[data-role='catalogue-item']", count: 2)
      expect(titles).not_to include("A film")
      expect(page).to have_checked_field("Série", visible: :all)
    end

    it "applies a filter as soon as its box is checked, with no button to click" do
      visit catalogue_path

      within("aside[aria-label='Filtres']") { check "Série", allow_label_click: true }

      expect(page).to have_css("[data-role='catalogue-item']", count: 2)
      expect(titles).to match_array([ "Series one", "Series two" ])
    end

    it "applies the first year as soon as the field is left" do
      create(:anime, title_romaji: "Old", season_year: 1990)
      create(:anime, title_romaji: "New", season_year: 2010)
      visit catalogue_path

      fill_in "Année minimale", with: "2000"
      find_field("Année minimale").send_keys(:tab)

      expect(page).to have_css("[data-role='catalogue-item']", count: 1)
      expect(titles).to eq([ "New" ])
    end

    it "hides the button that only visitors without scripts need" do
      visit catalogue_path

      expect(page).to have_no_button("Appliquer")
    end
  end

  context "on a phone" do
    before { page.current_window.resize_to(390, 844) }

    it "shows the results without the filters column" do
      visit catalogue_path

      expect(page).to have_css("[data-role='catalogue-item']", count: 3)
      expect(page).to have_no_css("aside[aria-label='Filtres']")
    end
  end
end
