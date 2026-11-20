require "rails_helper"

RSpec.describe "Deleting the account", type: :system, js: true do
  include Warden::Test::Helpers

  let(:user) { create(:user) }

  before do
    Warden.test_mode!
    login_as(user, scope: :user)
  end

  after { Warden.test_reset! }

  it "deletes the account after the confirmation and goes back to the home page" do
    visit profile_path
    click_button "Supprimer mon compte"
    within("#delete-account") do
      fill_in "delete-account-confirm", with: "SUPPRIMER"
      click_button "Supprimer définitivement"
    end

    expect(page).to have_text("Ton compte et tes données ont été supprimés. À bientôt !")
    expect(User.exists?(user.id)).to be(false)
  end

  it "keeps the account when the user cancels" do
    visit profile_path
    click_button "Supprimer mon compte"
    within("#delete-account") { click_button "Annuler" }

    expect(page).to have_no_css("dialog[open]")
    expect(User.exists?(user.id)).to be(true)
  end
end
