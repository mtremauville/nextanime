require "rails_helper"

RSpec.describe "Navigation", type: :system do
  let(:tab_bar) { "nav[aria-label='Onglets']" }

  it "moves from one tab to another and keeps the current tab highlighted" do
    visit root_path
    expect(page).to have_css("#{tab_bar} a[aria-current='page']", text: "Découvrir")

    within(tab_bar) { click_link "Catalogue" }

    expect(page).to have_current_path(catalogue_path)
    expect(page).to have_css("main h1", text: "Catalogue")
    expect(page).to have_css("#{tab_bar} a[aria-current='page']", text: "Catalogue")
  end

  it "goes back home from the brand link" do
    visit calendar_path
    click_link "NextAnime"

    expect(page).to have_current_path(root_path)
  end
end
