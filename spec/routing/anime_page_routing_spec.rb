require "rails_helper"

RSpec.describe "Anime page routing", type: :routing do
  it "routes /anime/:id to the anime page" do
    expect(get: "/anime/12").to route_to(controller: "animes", action: "show", id: "12")
  end

  it "builds the path of an anime" do
    expect(Rails.application.routes.url_helpers.anime_path(12)).to eq("/anime/12")
  end

  it "keeps the catalogue where it was" do
    expect(get: "/catalogue").to route_to(controller: "animes", action: "index")
  end

  it "does not route anything else for an anime" do
    expect(post: "/anime").not_to be_routable
    expect(delete: "/anime/12").not_to be_routable
    expect(get: "/anime/12/edit").not_to be_routable
  end
end
