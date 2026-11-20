require "rails_helper"

RSpec.describe "Country routing", type: :routing do
  it "routes the choice of the country to the update of the country" do
    expect(patch: "/country").to route_to("countries#update")
  end

  it "has no page to show the country" do
    expect(get: "/country").not_to be_routable
  end
end
