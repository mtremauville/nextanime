require "rails_helper"

RSpec.describe "Password reset routes", type: :routing do
  it "routes the request of a link to the passwords controller of the app" do
    expect(get: "/users/password/new").to route_to("users/passwords#new")
    expect(post: "/users/password").to route_to("users/passwords#create")
  end

  it "routes the choice of a new password to the passwords controller of the app" do
    expect(get: "/users/password/edit").to route_to("users/passwords#edit")
    expect(patch: "/users/password").to route_to("users/passwords#update")
  end
end
