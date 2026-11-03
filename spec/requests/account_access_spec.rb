require "rails_helper"

RSpec.describe "Account access", type: :request do
  let(:document) { Capybara.string(response.body) }

  context "for a visitor" do
    before { get root_path }

    it "offers to sign in and to sign up in the header" do
      expect(document).to have_css(".na-header__tools .na-account a[href='/users/sign_in']", text: "Connexion")
      expect(document).to have_css(".na-header__tools .na-account a[href='/users/sign_up']", text: "Créer un compte")
    end
  end

  context "for a signed in user" do
    before do
      sign_in create(:user, email: "mickael@example.com")
      get root_path
    end

    it "shows the account and a sign out button in the header" do
      expect(document).to have_css(".na-header__tools .na-account span.na-avatar", text: "M")
      expect(document).to have_css(".na-header__tools .na-account button", text: "Déconnexion")
    end

    it "shows the e-mail address in the mobile menu" do
      expect(document).to have_css("dialog .na-menu__account", text: "mickael@example.com")
    end
  end

  describe "DELETE /users/sign_out" do
    it "signs the user out and shows the visitor header again" do
      sign_in create(:user)

      delete destroy_user_session_path
      follow_redirect!

      expect(document).to have_css("[role='status']", text: I18n.t("devise.sessions.signed_out"))
      expect(document).to have_css(".na-header__tools .na-account a[href='/users/sign_in']")
    end
  end
end
