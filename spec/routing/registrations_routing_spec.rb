require "rails_helper"

RSpec.describe "Registrations routing", type: :routing do
  it "routes POST /users to the app registrations controller" do
    expect(post: "/users").to route_to("users/registrations#create")
  end

  it "keeps the sign up form on GET /users/sign_up" do
    expect(get: "/users/sign_up").to route_to("users/registrations#new")
  end
end
