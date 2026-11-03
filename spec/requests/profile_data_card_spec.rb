require "rails_helper"

RSpec.describe "Personal data card on the profile page", type: :request do
  let(:user) { create(:user) }
  let(:page) { Capybara.string(response.body) }

  before do
    sign_in user
    get profile_path
  end

  it "offers to export the data" do
    expect(page).to have_css("h2", text: "Mes données")
    expect(page).to have_link("Exporter mes données", href: data_export_path)
  end

  it "sits right under the account form in the side column" do
    expect(page).to have_css(".na-profile-grid__side > .na-account-form + .na-data-card")
  end

  it "offers to delete the account through the confirmation dialog" do
    expect(page).to have_css(".na-data-card dialog#delete-account form[action='#{user_registration_path}']", visible: :all)
  end
end
