require "rails_helper"

RSpec.describe "Catalogue active filters", type: :system, js: true do
  before { page.current_window.resize_to(1280, 900) }

  it "removes a filter in one click and lists the anime again" do
    create(:anime, title_romaji: "Series", format: :tv)
    create(:anime, title_romaji: "Film", format: :movie)

    visit catalogue_path(formats: %w[movie])
    expect(page).to have_css("[data-role='catalogue-item']", count: 1)

    click_link "Retirer le filtre Film"

    expect(page).to have_css("[data-role='catalogue-item']", count: 2)
    expect(page).to have_no_css(".na-active-filters")
    expect(page).to have_current_path(catalogue_path)
  end

  it "shows the way back to the whole catalogue when nothing matches" do
    create(:anime, title_romaji: "Series", format: :tv)

    visit catalogue_path(formats: %w[movie])
    expect(page).to have_text("Aucun anime ne correspond")

    click_link "Voir tout le catalogue"

    expect(page).to have_css("[data-role='catalogue-item']", count: 1)
  end
end
