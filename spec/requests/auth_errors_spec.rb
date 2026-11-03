require "rails_helper"

RSpec.describe "Authentication errors", type: :request do
  def html
    Capybara.string(response.body)
  end

  describe "sign in" do
    let!(:user) { create(:user, email: "ayako@example.com", password: "a correct password is long") }

    def sign_in_with(email:, password:)
      post user_session_path, params: { user: { email: email, password: password } }
    end

    shared_examples "a refused sign in" do
      it "tells that the credentials are incorrect" do
        expect(html).to have_css("[role='alert']", text: "Adresse e-mail ou mot de passe incorrect.")
      end

      it "flags only the password field" do
        expect(html.find_field("Mot de passe", exact: true)["aria-invalid"]).to eq("true")
        expect(html.find_field("Adresse e-mail")["aria-invalid"]).to be_nil
      end

      it "never sends the password back" do
        expect(html.find_field("Mot de passe", exact: true).value).to be_blank
      end
    end

    context "with a wrong password" do
      before { sign_in_with(email: user.email, password: "wrong password is long") }

      it_behaves_like "a refused sign in"
    end

    context "with an unknown address" do
      before { sign_in_with(email: "nobody@example.com", password: "whatever password is long") }

      it_behaves_like "a refused sign in"
    end

    it "flags nothing on a fresh visit" do
      get new_user_session_path

      expect(html).not_to have_css("[aria-invalid]")
    end
  end

  describe "sign up" do
    def sign_up_with(email: "new@example.com", password: "a long enough password", confirmation: password)
      post user_registration_path, params: { user: {
        email: email,
        password: password,
        password_confirmation: confirmation,
        privacy_policy: "1"
      } }
    end

    it "shows no summary on a fresh visit" do
      get new_user_registration_path

      expect(html).not_to have_css("[role='alert']")
    end

    it "summarizes a single error and flags its field" do
      sign_up_with(confirmation: "a different long password")

      expect(html).to have_css("[role='alert']", text: "1 erreur empêche la création du compte.")
      expect(html).to have_css("#field_user_password_confirmation_error", text: "Les mots de passe ne correspondent pas.")
      expect(html.find_field("Confirmer le mot de passe")["aria-invalid"]).to eq("true")
      expect(html.find_field("Adresse e-mail")["aria-invalid"]).to be_nil
    end

    it "explains a password that is too short" do
      sign_up_with(password: "short", confirmation: "short")

      expect(html).to have_css(
        "#field_user_password_error",
        text: "Ce mot de passe est trop court (12 caractères minimum)."
      )
    end

    it "summarizes several errors and offers to sign in when the address is already used" do
      create(:user, email: "taken@example.com")

      sign_up_with(email: "taken@example.com", confirmation: "a different long password")

      expect(html).to have_css("[role='alert']", text: "2 erreurs empêchent la création du compte.")
      expect(html).to have_css("#field_user_email_error", text: "Cette adresse est déjà utilisée.")
      expect(html).to have_css("#field_user_email_error a[href='/users/sign_in']", text: "Te connecter ?")
    end
  end
end
