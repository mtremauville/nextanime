require "rails_helper"

RSpec.describe "Sessions routing", type: :routing do
  it "routes POST /users/sign_in to the app sessions controller" do
    expect(post: "/users/sign_in").to route_to("users/sessions#create")
  end

  it "routes the sign in form on GET /users/sign_in to the app sessions controller" do
    expect(get: "/users/sign_in").to route_to("users/sessions#new")
  end

  it "routes the sign out on DELETE /users/sign_out to the app sessions controller" do
    expect(delete: "/users/sign_out").to route_to("users/sessions#destroy")
  end
end
