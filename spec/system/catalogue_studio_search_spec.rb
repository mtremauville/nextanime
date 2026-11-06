require "rails_helper"

RSpec.describe "Searching the studios of the catalogue filters", type: :system, js: true do
  let(:search_label) { "Rechercher un studio" }

  before do
    [ "Madhouse", "Bones", "Kyoto Animation", "Éclair" ].each do |name|
      create(:anime, title_romaji: "#{name} show", studios: [ create(:studio, name: name) ])
    end
  end

  describe "in the column" do
    let(:column) { ".na-catalogue-layout__filters" }

    before do
      page.current_window.resize_to(1280, 900)
      visit catalogue_path
    end

    it "shows the field once the script is there" do
      within(column) { expect(page).to have_field(search_label) }
    end

    it "narrows the studios to the ones that hold the text" do
      within(column) do
        fill_in search_label, with: "mad"

        expect(page).to have_field("Madhouse")
        expect(page).to have_no_field("Bones")
        expect(page).to have_no_field("Kyoto Animation")
      end
    end

    it "ignores the case and the accents" do
      within(column) do
        fill_in search_label, with: "ECLAIR"

        expect(page).to have_field("Éclair")
        expect(page).to have_no_field("Madhouse")
      end
    end

    it "says when no studio matches" do
      within(column) do
        fill_in search_label, with: "zzz"

        expect(page).to have_text("Aucun studio ne correspond")
        expect(page).to have_no_field("Madhouse")
      end
    end

    it "shows every studio again when the field is emptied" do
      within(column) do
        fill_in search_label, with: "mad"
        expect(page).to have_no_field("Bones")

        fill_in search_label, with: ""

        expect(page).to have_field("Bones")
        expect(page).to have_no_text("Aucun studio ne correspond")
      end
    end

    it "does not send the form on Enter nor when the field is left" do
      within(column) do
        fill_in search_label, with: "mad"
        find_field(search_label).send_keys(:enter)
        find(".na-filters__title").click

        expect(page).to have_no_field("Bones")
      end
      expect(page).to have_current_path(catalogue_path)
    end
  end

  describe "in the sheet" do
    before do
      page.current_window.resize_to(390, 844)
      visit catalogue_path
      click_button "Filtres"
    end

    it "narrows the studios to the ones that hold the text" do
      within("dialog") do
        fill_in search_label, with: "bones"

        expect(page).to have_css("label", text: "Bones")
        expect(page).to have_no_css("label", text: "Madhouse")
      end
    end

    it "filters the catalogue with the studio found, when the button is pressed" do
      within("dialog") do
        fill_in search_label, with: "bones"
        check "Bones", allow_label_click: true
        click_button "Voir les résultats"
      end

      expect(page).to have_css(".na-active-filters", text: "Bones")
      expect(page).to have_text("Bones show")
      expect(page).to have_no_text("Madhouse show")
    end
  end
end
