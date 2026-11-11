require "rails_helper"

RSpec.describe "The watchlist in the catalogue", type: :request do
  let(:document) { Capybara.string(response.body) }
  let(:member) { create(:user) }
  let!(:monster) { create(:anime, title_romaji: "Monster", title_english: nil, popularity: 20) }
  let!(:pluto) { create(:anime, title_romaji: "Pluto", title_english: nil, popularity: 10) }

  before do
    sign_in member
    create(:watchlist_entry, user: member, anime: monster)
  end

  it "marks the anime that are in the watchlist of the member" do
    get catalogue_path

    expect(document.find("li", text: "Monster")).to have_css(".na-poster-card__listed", text: "Dans ma liste")
  end

  it "marks no other anime" do
    get catalogue_path

    expect(document.find("li", text: "Pluto")).to have_no_css(".na-poster-card__listed")
  end

  it "does not mark an anime that is in the watchlist of someone else" do
    create(:watchlist_entry, user: create(:user), anime: pluto)

    get catalogue_path

    expect(document.find("li", text: "Pluto")).to have_no_css(".na-poster-card__listed")
  end

  it "marks the anime that load more adds to the grid" do
    get catalogue_path, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    added = response.body[%r{<turbo-stream action="append" target="catalogue-grid"><template>(.*?)</template></turbo-stream>}m, 1]
    expect(Capybara.string(added).find("li", text: "Monster")).to have_css(".na-poster-card__listed")
  end
end
