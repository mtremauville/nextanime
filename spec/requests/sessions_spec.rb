require "rails_helper"

RSpec.describe "Sign in", type: :request do
  let(:document) { Capybara.string(response.body) }
  let(:email) { "mika@example.com" }
  let(:password) { "correct-horse-battery" }

  describe "GET /users/sign_in" do
    before { get new_user_session_path }

    it "greets the returning user" do
      expect(document).to have_css("h1", text: "Content de te revoir")
    end

    it "marks the sign in tab as the current one" do
      expect(document).to have_css("nav[aria-label='Connexion ou inscription'] a[aria-current='page']", text: "Connexion")
    end

    it "links to the sign up tab" do
      expect(document).to have_link("Créer un compte", href: new_user_registration_path)
    end

    it "asks for the e-mail address and the password" do
      expect(document).to have_field("Adresse e-mail", type: "email")
      expect(document).to have_field("Mot de passe", type: "password")
    end

    it "offers to remember the user" do
      expect(document).to have_unchecked_field("Se souvenir de moi")
    end

    it "links to the password reset" do
      expect(document).to have_link("Mot de passe oublié ?", href: new_user_password_path)
    end

    it "submits with a clear label" do
      expect(document).to have_button("Se connecter")
    end

    it "lets visitors try the app without an account" do
      expect(document).to have_link("Essayer sans compte", href: root_path)
      expect(document).to have_text("Tu peux swiper tout de suite")
    end
  end

  describe "POST /users/sign_in" do
    before { create(:user, email: email, password: password) }

    it "signs the user in and goes home" do
      post user_session_path, params: { user: { email: email, password: password } }

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(document).to have_css("[role='status']", text: I18n.t("devise.sessions.signed_in"))
    end

    context "with a wrong password" do
      before { post user_session_path, params: { user: { email: email, password: "wrong-password" } } }

      it "keeps the e-mail address in the form" do
        expect(document).to have_field("Adresse e-mail", with: email)
      end

      it "never sends the password back" do
        expect(document).to have_no_css("input[type='password'][value]")
      end
    end
  end
end
