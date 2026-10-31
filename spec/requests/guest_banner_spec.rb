require "rails_helper"

RSpec.describe "Guest banner", type: :request do
  def page
    Capybara.string(response.body)
  end

  %w[/ /catalogue /recos].each do |path|
    it "is shown to a visitor on #{path}" do
      get path

      expect(page).to have_css(".na-guest-banner[role='status']", text: "Mode invité")
    end
  end

  it "is hidden for a signed in user" do
    sign_in create(:user)

    get root_path

    expect(page).to have_no_css(".na-guest-banner")
  end

  it "is hidden on the authentication pages" do
    get new_user_session_path

    expect(page).to have_no_css(".na-guest-banner")
  end
end
