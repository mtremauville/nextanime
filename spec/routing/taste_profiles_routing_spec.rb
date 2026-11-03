require "rails_helper"

RSpec.describe "Taste profile routing", type: :routing do
  it "routes DELETE /taste_profile/reset to taste_profiles#reset" do
    expect(delete: "/taste_profile/reset").to route_to("taste_profiles#reset")
  end

  it "does not expose any other taste profile route" do
    expect(get: "/taste_profile").not_to be_routable
    expect(get: "/taste_profile/reset").not_to be_routable
    expect(post: "/taste_profile/reset").not_to be_routable
    expect(patch: "/taste_profile/reset").not_to be_routable
  end
end
