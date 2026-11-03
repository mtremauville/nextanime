require "rails_helper"

RSpec.describe "Password reset routing", type: :routing do
  it "routes GET /users/password/new to the request form" do
    expect(get: "/users/password/new").to route_to("devise/passwords#new")
  end

  it "routes POST /users/password to the e-mail sending" do
    expect(post: "/users/password").to route_to("devise/passwords#create")
  end

  it "routes GET /users/password/edit to the new password form" do
    expect(get: "/users/password/edit").to route_to("devise/passwords#edit")
  end

  it "routes PATCH /users/password to the password update" do
    expect(patch: "/users/password").to route_to("devise/passwords#update")
  end
end
