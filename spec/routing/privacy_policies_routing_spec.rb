require "rails_helper"

RSpec.describe "Privacy policy routing", type: :routing do
  it "routes /confidentialite to the privacy policy page" do
    expect(get: "/confidentialite").to route_to("privacy_policies#show")
  end

  it "names the route privacy_policy" do
    expect(privacy_policy_path).to eq("/confidentialite")
  end
end
