require "rails_helper"

RSpec.describe "Watchlist routing", type: :routing do
  it "adds an anime to the watchlist from its page" do
    expect(post: "/anime/12/watchlist").to route_to("watchlist_entries#create", anime_id: "12")
  end

  it "names the route after the anime and its watchlist entry" do
    expect(anime_watchlist_entry_path(12)).to eq("/anime/12/watchlist")
  end
end
