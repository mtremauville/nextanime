require "rails_helper"

RSpec.describe "Sorting the catalogue", type: :system, js: true do
  before do
    create(:anime, title_romaji: "Popular but average", popularity: 100, average_score: 50, format: :tv)
    create(:anime, title_romaji: "Rare but loved", popularity: 10, average_score: 90, format: :tv)
  end

  def titles
    page.all("[data-role='catalogue-item'] h2").map { |node| node.text.strip }
  end

  context "on a wide screen" do
    before { page.current_window.resize_to(1280, 900) }

    it "ranks by popularity first, then by the chosen sort as soon as it is chosen" do
      visit catalogue_path
      expect(titles).to eq([ "Popular but average", "Rare but loved" ])

      select "Note", from: "Trier par"

      expect(page).to have_current_path(/sort=score/)
      expect(titles).to eq([ "Rare but loved", "Popular but average" ])
      expect(page).to have_select("Trier par", selected: "Note")
    end

    it "keeps the sort when searching" do
      visit catalogue_path(sort: "score")

      find("form[role='search'] input[name='q']").set("a").send_keys(:enter)

      expect(page).to have_current_path(/q=a/)
      expect(titles).to eq([ "Rare but loved", "Popular but average" ])
      expect(page).to have_select("Trier par", selected: "Note")
    end

    it "keeps the sort when a filter is ticked" do
      visit catalogue_path(sort: "score")

      within("aside[aria-label='Filtres']") { check "Série", allow_label_click: true }

      expect(page).to have_current_path(/sort=score/)
      expect(page).to have_current_path(/formats/)
      expect(page).to have_select("Trier par", selected: "Note")
    end

    it "hides the button that only visitors without scripts need" do
      visit catalogue_path

      expect(page).to have_no_button("Trier")
    end
  end

  context "on a phone" do
    before { page.current_window.resize_to(390, 844) }

    it "offers the sort over the results" do
      visit catalogue_path

      expect(page).to have_select("Trier par")
      select "Note", from: "Trier par"
      expect(page).to have_current_path(/sort=score/)
      expect(titles).to eq([ "Rare but loved", "Popular but average" ])
    end
  end
end
