require "rails_helper"

RSpec.describe "Recommendations routing", type: :routing do
  it "routes /recos to the list of recommendations" do
    expect(get: "/recos").to route_to("recommendations#index")
  end
end
