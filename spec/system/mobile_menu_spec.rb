require "rails_helper"

RSpec.describe "Mobile menu", type: :system, js: true do
  let(:opener) { "button[aria-label='Ouvrir le menu']" }

  before do
    page.current_window.resize_to(390, 844)
    visit root_path
  end

  it "is closed by default" do
    expect(page).to have_no_css("#mobile-menu[open]")
    expect(page).to have_css("#{opener}[aria-expanded='false']")
  end

  it "opens from the burger button" do
    click_button "Ouvrir le menu"

    expect(page).to have_css("#mobile-menu[open] h2", text: "Menu")
    expect(page).to have_css("#{opener}[aria-expanded='true']")
  end

  it "closes with its close button" do
    click_button "Ouvrir le menu"
    click_button "Fermer le menu"

    expect(page).to have_no_css("#mobile-menu[open]")
    expect(page).to have_css("#{opener}[aria-expanded='false']")
  end

  it "closes with the Escape key" do
    click_button "Ouvrir le menu"
    find_button("Fermer le menu").send_keys(:escape)

    expect(page).to have_no_css("#mobile-menu[open]")
    expect(page).to have_css("#{opener}[aria-expanded='false']")
  end

  it "navigates to a page from the menu" do
    click_button "Ouvrir le menu"
    within("#mobile-menu") { click_link "Catalogue" }

    expect(page).to have_current_path(catalogue_path)
    expect(page).to have_no_css("#mobile-menu[open]")
  end
end
