require "rails_helper"

RSpec.describe "Browsing the catalogue", type: :system, js: true do
  before do
    13.times do |index|
      create(:anime, title_romaji: "Anime #{index}", title_english: nil, popularity: 1000 - index,
                     cover_image_url: "https://img.test/cover.jpg")
    end
  end

  it "goes from page to page on a wide screen" do
    visit catalogue_path

    expect(page).to have_css("[data-role='catalogue-item']", count: 12)
    expect(page).to have_no_css("#load-more")

    within("nav[aria-label='Pagination']") { click_link "Suivant →" }

    expect(page).to have_css("[data-role='catalogue-item']", count: 1)
    expect(page).to have_css("h2", text: "Anime 12")
    expect(page).to have_current_path(catalogue_path(page: 2))
  end

  it "loads more anime on a phone without leaving the page" do
    page.current_window.resize_to(390, 844)

    visit catalogue_path

    expect(page).to have_css("[data-role='catalogue-item']", count: 12)
    expect(page).to have_no_css("nav[aria-label='Pagination']")
    expect(page).to have_css("#load-more", text: /12 sur 13/i)

    click_link "Voir plus"

    expect(page).to have_css("[data-role='catalogue-item']", count: 13)
    expect(page).to have_css("#load-more", text: /13 sur 13/i)
    expect(page).to have_no_link("Voir plus")
    expect(page).to have_current_path(catalogue_path)
  end

  def create_monsters
    13.times do |index|
      create(:anime, title_romaji: "Monster #{index}", title_english: nil, popularity: 500 - index,
                     cover_image_url: "https://img.test/cover.jpg")
    end
  end

  it "searches the catalogue and pages through the results" do
    create_monsters

    visit catalogue_path
    fill_in "Rechercher un anime", with: "monster\n"

    expect(page).to have_css("[data-role='catalogue-item']", count: 12)
    expect(page).to have_current_path(catalogue_path(q: "monster"))

    within("nav[aria-label='Pagination']") { click_link "Suivant →" }

    expect(page).to have_css("[data-role='catalogue-item']", count: 1)
    expect(page).to have_css("h2", text: "Monster 12")
    expect(page).to have_current_path(catalogue_path(page: 2, q: "monster"))
  end

  it "keeps the search when loading more anime on a phone" do
    page.current_window.resize_to(390, 844)
    create_monsters

    visit catalogue_path
    fill_in "Rechercher un anime", with: "monster\n"

    expect(page).to have_css("[data-role='catalogue-item']", count: 12)

    click_link "Voir plus"

    expect(page).to have_css("[data-role='catalogue-item']", count: 13)
    expect(page).to have_css("h2", text: "Monster 12")
    expect(page).to have_no_css("h2", text: "Anime 0")
  end
end
