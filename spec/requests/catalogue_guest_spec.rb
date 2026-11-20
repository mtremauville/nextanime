require "rails_helper"

RSpec.describe "Catalogue seen by a visitor", type: :request do
  let!(:anime) { create(:anime, title_romaji: "Perfect Blue") }

  def page = Capybara.string(response.body)

  it "is open to someone who is not signed in" do
    get catalogue_path

    expect(response).to have_http_status(:ok)
  end

  it "links each card to the page of its anime" do
    get catalogue_path

    expect(page).to have_link("Perfect Blue", href: anime_path(anime))
  end

  it "opens the page of an anime to a visitor" do
    get anime_path(anime)

    expect(response).to have_http_status(:ok)
  end

  it "shows no watchlist badge on the cards, since a visitor has no watchlist" do
    get catalogue_path

    expect(page).to have_no_text(/dans ma liste/i)
  end
end
