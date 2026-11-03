require "rails_helper"

RSpec.describe "Account access", type: :system do
  let(:email) { "mika@example.com" }
  let(:password) { "correct-horse-battery" }

  before { create(:user, email: email, password: password) }

  def sign_in_through_the_form
    visit new_user_session_path
    fill_in "Adresse e-mail", with: email
    fill_in "Mot de passe", with: password
    click_button "Se connecter"
  end

  it "signs in and out from the header" do
    sign_in_through_the_form

    expect(page).to have_css("[role='status']", text: I18n.t("devise.sessions.signed_in"))

    within(".na-header__tools") { click_button "Déconnexion" }

    expect(page).to have_css("[role='status']", text: I18n.t("devise.sessions.signed_out"))
    expect(page).to have_css(".na-header__tools a[href='/users/sign_in']")
  end

  it "signs out from the burger menu", :js do
    page.driver.browser.manage.window.resize_to(390, 844)
    sign_in_through_the_form

    click_button "Ouvrir le menu"
    within("#mobile-menu") do
      expect(page).to have_text(email)
      click_button "Déconnexion"
    end

    expect(page).to have_css("[role='status']", text: I18n.t("devise.sessions.signed_out"))
  end

  it "offers the guest mode and the sign in link in the burger menu", :js do
    page.driver.browser.manage.window.resize_to(390, 844)
    visit root_path

    click_button "Ouvrir le menu"
    within("#mobile-menu") do
      expect(page).to have_text("Ton profil est gardé sur cet appareil")
      click_link "Connexion"
    end

    expect(page).to have_css("h1", text: "Content de te revoir")
  end
end
