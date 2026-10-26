require "rails_helper"

RSpec.describe "Mobile menu theme choice", type: :system, js: true do
  let(:dark_button) { "#mobile-menu button[data-theme-theme-param='dark']" }
  let(:light_button) { "#mobile-menu button[data-theme-theme-param='light']" }

  before do
    page.current_window.resize_to(390, 844)
    visit root_path
    page.execute_script("localStorage.clear()")
    visit root_path
    click_button "Ouvrir le menu"
  end

  after { page.execute_script("localStorage.clear()") }

  it "shows the current theme as pressed" do
    expect(page).to have_css("#{dark_button}[aria-pressed='true']")
    expect(page).to have_css("#{light_button}[aria-pressed='false']")
  end

  it "applies the chosen theme and reflects it on the buttons" do
    click_button "Clair"

    expect(page).to have_css('html[data-bs-theme="light"]')
    expect(page).to have_css("#{light_button}[aria-pressed='true']")
    expect(page).to have_css("#{dark_button}[aria-pressed='false']")
  end

  it "keeps the chosen theme after a reload" do
    click_button "Clair"
    page.refresh

    expect(page).to have_css('html[data-bs-theme="light"]')
  end
end
