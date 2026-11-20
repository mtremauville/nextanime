require "rails_helper"

RSpec.describe "Catalogue filters sheet", type: :system, js: true do
  let(:open_sheet) { "dialog#filters-sheet[open]" }

  def open_filters(label = "Filtres")
    click_button label, exact: true
    expect(page).to have_css(open_sheet)
  end

  def focus_class
    page.evaluate_script("document.activeElement.className")
  end

  # Where the focus is: inside the dialog, or on which element when it is outside.
  def focus_place
    page.evaluate_script(<<~JS)
      (() => {
        const element = document.activeElement
        const place = element.closest("dialog") ? "inside" : "outside"
        return `${place}: <${element.tagName.toLowerCase()}> id=${element.id} class=${element.className}`
      })()
    JS
  end

  context "on a phone" do
    before { page.current_window.resize_to(390, 844) }

    it "opens from the button and closes with the cross" do
      visit catalogue_path
      expect(page).to have_no_css(open_sheet, visible: :all)

      open_filters
      within("dialog#filters-sheet") { click_button "Fermer les filtres" }

      expect(page).to have_no_css(open_sheet, visible: :all)
    end

    it "closes on Escape and gives the focus back to the button" do
      visit catalogue_path
      open_filters

      page.send_keys(:escape)

      expect(page).to have_no_css(open_sheet, visible: :all)
      expect(focus_class).to include("na-filters-trigger")
    end

    it "closes on a click on the backdrop" do
      visit catalogue_path
      open_filters

      page.driver.browser.action.move_to_location(195, 40).click.perform

      expect(page).to have_no_css(open_sheet, visible: :all)
    end

    it "keeps the focus inside the dialog while tabbing" do
      visit catalogue_path
      open_filters

      places = Array.new(40) do |index|
        page.send_keys(:tab)
        "tab #{index + 1} -> #{focus_place}"
      end

      # At the end of the cycle the focus leaves the page for the browser (the body), then comes back.
      # What must never happen is a landing on an element behind the sheet.
      expect(places.first).to include("-> inside")
      expect(places.grep_v(/-> inside|<body>/)).to eq([])
    end

    it "filters the catalogue from the sheet and closes it" do
      create(:anime, title_romaji: "Series", format: :tv)
      create(:anime, title_romaji: "Film", format: :movie)
      visit catalogue_path
      expect(page).to have_css("[data-role='catalogue-item']", count: 2)

      open_filters
      within("dialog#filters-sheet") do
        check "Film", allow_label_click: true
        click_button "Voir les résultats"
      end

      expect(page).to have_css("[data-role='catalogue-item']", count: 1)
      expect(page).to have_button("Filtres (1)")
      expect(page).to have_no_css(open_sheet, visible: :all)
    end

    it "resets from the sheet and keeps the search" do
      visit catalogue_path(q: "Ser", formats: %w[tv])
      open_filters("Filtres (1)")

      within("dialog#filters-sheet") { click_link "Réinitialiser" }

      expect(page).to have_current_path(catalogue_path(q: "Ser"))
      expect(page).to have_button("Filtres", exact: true)
    end
  end

  context "on a wide screen" do
    before { page.current_window.resize_to(1280, 900) }

    it "does not offer the sheet, the column of filters is there" do
      visit catalogue_path

      expect(page).to have_no_button("Filtres", exact: true)
      expect(page).to have_css(".na-catalogue-layout__filters .na-filters")
    end
  end
end
