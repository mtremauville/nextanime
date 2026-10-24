require "rails_helper"

RSpec.describe "Styleguide routing", type: :routing do
  it "routes GET /styleguide to styleguide#show" do
    expect(get: "/styleguide").to route_to("styleguide#show")
  end
end
