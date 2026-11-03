require "rails_helper"

RSpec.describe "Inline styles", type: :request do
  PAGES_UNDER_CONTENT_SECURITY_POLICY = {
    "the home page" => "/",
    "the styleguide" => "/styleguide",
    "the sign in page" => "/users/sign_in",
    "the sign up page" => "/users/sign_up"
  }.freeze

  PAGES_UNDER_CONTENT_SECURITY_POLICY.each do |name, path|
    it "renders #{name} without any style attribute, which the policy would refuse" do
      get path

      expect(response).to have_http_status(:ok)
      expect(Capybara.string(response.body)).not_to have_css("[style]", visible: :all)
    end
  end
end
