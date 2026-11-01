require "rails_helper"

RSpec.describe "Changing the account settings", type: :system, js: true do
  include Warden::Test::Helpers

  let(:password) { "a-long-password-123" }
  let!(:user) { create(:user, email: "me@example.com", password: password, password_confirmation: password) }

  before do
    Warden.test_mode!
    login_as(user, scope: :user)
  end

  after { Warden.test_reset! }

  it "changes the e-mail address from the profile page" do
    visit profile_path
    fill_in "Adresse e-mail", with: "new@example.com"
    fill_in "Mot de passe actuel", with: password
    click_button "Enregistrer"

    expect(page).to have_text("Tes informations ont été mises à jour.")
    expect(page).to have_current_path(profile_path)
    expect(page).to have_css(".na-profile-header__meta", text: "new@example.com")
    expect(user.reload.email).to eq("new@example.com")
  end

  it "keeps the user on the profile page and flags the current password when it is wrong" do
    visit profile_path
    fill_in "Mot de passe actuel", with: "wrong-password-123"
    click_button "Enregistrer"

    expect(page).to have_text("1 erreur empêche l'enregistrement.")
    expect(page).to have_css("input[name='user[current_password]'][aria-invalid='true']")
    expect(user.reload.email).to eq("me@example.com")
  end
end
