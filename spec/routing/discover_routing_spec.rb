require "rails_helper"

RSpec.describe "Discover routing", type: :routing do
  it "routes /decouvrir to the swipe deck" do
    expect(get: "/decouvrir").to route_to("swipes#index")
  end

  it "has a named route" do
    expect(Rails.application.routes.url_helpers.discover_path).to eq("/decouvrir")
  end
end
