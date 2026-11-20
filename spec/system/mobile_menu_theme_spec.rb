require "rails_helper"

RSpec.describe "Mobile menu theme switch", type: :system, js: true do
  let(:theme_switch) { "#mobile-menu button[role='switch']" }

  before do
    page.current_window.resize_to(390, 844)
    visit discover_path
    page.execute_script("localStorage.clear()")
    visit discover_path
    click_button "Ouvrir le menu"
  end

  after { page.execute_script("localStorage.clear()") }

  it "is on while the theme is dark" do
    expect(page).to have_css("#{theme_switch}[aria-checked='true']", text: "Mode sombre")
  end

  it "applies the light theme when it is switched off" do
    find(theme_switch).click

    expect(page).to have_css('html[data-bs-theme="light"]')
    expect(page).to have_css("#{theme_switch}[aria-checked='false']")
  end

  it "goes back to the dark theme when it is switched on again" do
    2.times { find(theme_switch).click }

    expect(page).to have_css('html[data-bs-theme="dark"]')
    expect(page).to have_css("#{theme_switch}[aria-checked='true']")
  end

  it "keeps the chosen theme after a reload and shows it on the switch" do
    find(theme_switch).click
    page.refresh
    click_button "Ouvrir le menu"

    expect(page).to have_css('html[data-bs-theme="light"]')
    expect(page).to have_css("#{theme_switch}[aria-checked='false']")
  end
end
