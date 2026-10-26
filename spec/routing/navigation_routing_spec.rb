require "rails_helper"

RSpec.describe "Navigation routing", type: :routing do
  it "routes the root to the swipe page" do
    expect(get: "/").to route_to("swipes#index")
  end

  it "routes /catalogue to the catalogue" do
    expect(get: "/catalogue").to route_to("animes#index")
  end

  it "routes /recos to the recommendations" do
    expect(get: "/recos").to route_to("recommendations#index")
  end

  it "routes /watchlist to the watchlist" do
    expect(get: "/watchlist").to route_to("watchlist_entries#index")
  end

  it "routes /calendrier to the season calendar" do
    expect(get: "/calendrier").to route_to("calendar#show")
  end
end
