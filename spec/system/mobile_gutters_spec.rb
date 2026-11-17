require "rails_helper"

RSpec.describe "Side gutters on a phone", type: :system, js: true do
  include Warden::Test::Helpers

  # The mobile mockups keep 16 px between the screen edge and the content.
  let(:gutter) { 16 }
  let(:anime) { create(:anime) }

  before { page.current_window.resize_to(393, 852) }

  after { Warden.test_reset! }

  def left_edge_of(element_script)
    page.evaluate_script("Math.round(#{element_script}.getBoundingClientRect().left)")
  end

  it "keeps the gutter on the title of an anime page" do
    visit anime_path(anime)
    expect(page).to have_css("main h1")

    expect(left_edge_of('document.querySelector("main h1")')).to eq(gutter)
  end

  it "keeps the gutter on the 'Où regarder' block of an anime page" do
    create(:tmdb_match, anime: anime)
    crunchyroll = create(:streaming_platform, name: "Crunchyroll", slug: "crunchyroll")
    create(:streaming_availability, anime: anime, streaming_platform: crunchyroll, offer_type: :flatrate, country_code: "FR")
    visit anime_path(anime)
    expect(page).to have_css("main h2", text: "Où regarder")

    expect(left_edge_of('document.querySelector(".na-where-to-watch")')).to eq(gutter)
  end

  it "keeps the gutter on the title of the watchlist" do
    Warden.test_mode!
    login_as(create(:user), scope: :user)
    visit "/watchlist"
    expect(page).to have_css("main h1")

    expect(left_edge_of('document.querySelector("main h1")')).to eq(gutter)
  end
end
