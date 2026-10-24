require "rails_helper"

RSpec.describe "Theme toggle", type: :system, js: true do
  let(:toggle_label) { "Basculer entre thème clair et sombre" }

  after { page.execute_script("window.localStorage.clear()") }

  it "starts in the dark theme" do
    visit styleguide_path

    expect(page).to have_css('html[data-bs-theme="dark"]')
  end

  it "switches to the light theme and back to dark" do
    visit styleguide_path

    click_button toggle_label
    expect(page).to have_css('html[data-bs-theme="light"]')

    click_button toggle_label
    expect(page).to have_css('html[data-bs-theme="dark"]')
  end

  it "remembers the chosen theme after a reload" do
    visit styleguide_path
    click_button toggle_label
    expect(page).to have_css('html[data-bs-theme="light"]')

    visit styleguide_path

    expect(page).to have_css('html[data-bs-theme="light"]')
  end
end
