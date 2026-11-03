require "rails_helper"

RSpec.describe "Account deletion routing", type: :routing do
  it "routes DELETE /users to the app registrations controller" do
    expect(delete: "/users").to route_to("users/registrations#destroy")
  end
end
