require "rails_helper"

RSpec.describe "Swipes routing", type: :routing do
  it "routes POST /swipes to swipes#create" do
    expect(post: "/swipes").to route_to("swipes#create")
  end

  it "keeps the deck on the root path" do
    expect(get: "/").to route_to("swipes#index")
  end

  it "does not expose any other swipe route" do
    expect(get: "/swipes").not_to be_routable
    expect(delete: "/swipes/1").not_to be_routable
  end
end
