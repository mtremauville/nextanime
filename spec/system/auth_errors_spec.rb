require "rails_helper"

RSpec.describe "Authentication errors", type: :system do
  let!(:user) { create(:user, email: "ayako@example.com", password: "a correct password is long") }

  it "explains a refused sign in and flags the password" do
    visit new_user_session_path
    fill_in "Adresse e-mail", with: user.email
    fill_in "Mot de passe", with: "wrong password is long"
    click_on "Se connecter"

    expect(page).to have_css("[role='alert']", text: "Adresse e-mail ou mot de passe incorrect.")
    expect(page).to have_css("input[type='password'][aria-invalid='true']")
    expect(page).to have_field("Adresse e-mail", with: user.email)
  end

  it "offers to sign in when the address is already used" do
    visit new_user_registration_path
    fill_in "Adresse e-mail", with: user.email
    fill_in "Mot de passe", with: "a long enough password", exact: true
    fill_in "Confirmer le mot de passe", with: "a long enough password"
    find("input[type='checkbox'][name='user[privacy_policy]']").check
    click_on "Créer mon compte"

    expect(page).to have_css("[role='alert']", text: "1 erreur empêche la création du compte.")
    expect(page).to have_text("Cette adresse est déjà utilisée.")

    click_on "Te connecter ?"

    expect(page).to have_current_path(new_user_session_path)
  end
end
