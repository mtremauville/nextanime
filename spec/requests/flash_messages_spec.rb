require "rails_helper"

RSpec.describe "Flash messages", type: :request do
  let(:document) { Capybara.string(response.body) }

  it "shows the notice set by Devise after signing out" do
    sign_in create(:user)

    delete destroy_user_session_path
    follow_redirect!

    expect(document).to have_css("[role='status']", text: I18n.t("devise.sessions.signed_out"))
  end

  it "shows nothing when there is no flash" do
    get root_path

    expect(document).to have_no_css(".na-alert")
  end
end
