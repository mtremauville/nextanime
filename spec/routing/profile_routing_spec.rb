require "rails_helper"
RSpec.describe "Profile routing", type: :routing do
  it "routes GET /profil to profiles#show" do
    expect(get: "/profil").to route_to("profiles#show")
  end

  it "does not let the profile page be posted to" do
    expect(post: "/profil").not_to be_routable
  end
end
