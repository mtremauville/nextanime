require "rails_helper"

RSpec.describe "Sign up", type: :request do
  let(:document) { Capybara.string(response.body) }
  let(:email) { "new@example.com" }
  let(:password) { "correct-horse-battery" }
  let(:password_confirmation) { password }
  let(:privacy_policy) { "1" }
  let(:params) do
    {
      user: {
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        privacy_policy: privacy_policy
      }
    }
  end

  describe "GET /users/sign_up" do
    before { get new_user_registration_path }

    it "invites the visitor to join" do
      expect(document).to have_css("h1", text: "Rejoins NextAnime")
    end

    it "marks the sign up tab as the current one" do
      expect(document).to have_css("nav[aria-label='Connexion ou inscription'] a[aria-current='page']", text: "Créer un compte")
    end

    it "links to the sign in tab" do
      expect(document).to have_link("Connexion", href: new_user_session_path)
    end

    it "asks for the e-mail address and a confirmed password" do
      expect(document).to have_field("Adresse e-mail", type: "email")
      expect(document).to have_field("Mot de passe", type: "password", exact: true)
      expect(document).to have_field("Confirmer le mot de passe", type: "password")
    end

    it "reminds the minimum password length" do
      expect(document).to have_text("12 caractères minimum.")
    end

    it "asks to accept the privacy policy" do
      expect(document).to have_unchecked_field("J'accepte la politique de confidentialité")
    end

    it "submits with a clear label" do
      expect(document).to have_button("Créer mon compte")
    end

    it "lets visitors try the app without an account" do
      expect(document).to have_link("Essayer sans compte", href: root_path)
    end
  end

  describe "POST /users" do
    context "with valid data" do
      it "creates the account" do
        expect { post user_registration_path, params: params }.to change(User, :count).by(1)
      end

      it "signs the user in and goes home" do
        post user_registration_path, params: params

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(document).to have_css("[role='status']", text: I18n.t("devise.registrations.signed_up"))
      end
    end

    context "when the privacy policy is not accepted" do
      let(:privacy_policy) { "0" }

      it "does not create the account" do
        expect { post user_registration_path, params: params }.not_to change(User, :count)
      end

      it "re-renders the form so that Turbo can display it" do
        post user_registration_path, params: params

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "explains that the policy must be accepted" do
        post user_registration_path, params: params

        expect(document).to have_css("#field_user_privacy_policy_error[role='alert']", text: "Tu dois accepter la politique de confidentialité.")
      end

      it "keeps the e-mail address but never sends the passwords back" do
        post user_registration_path, params: params

        expect(document).to have_field("Adresse e-mail", with: email)
        expect(document).to have_no_css("input[type='password'][value]")
      end
    end

    context "when the privacy policy field is missing" do
      it "does not create the account" do
        params[:user].delete(:privacy_policy)

        expect { post user_registration_path, params: params }.not_to change(User, :count)
      end
    end

    context "with a password that is too short" do
      let(:password) { "short" }

      it "does not create the account and explains why" do
        expect { post user_registration_path, params: params }.not_to change(User, :count)
        expect(document).to have_css("#field_user_password_error[role='alert']")
      end
    end

    context "when the passwords differ" do
      let(:password_confirmation) { "another-long-password" }

      it "does not create the account and explains why" do
        expect { post user_registration_path, params: params }.not_to change(User, :count)
        expect(document).to have_css("#field_user_password_confirmation_error[role='alert']")
      end
    end

    context "when the e-mail address is already used" do
      before { create(:user, email: email) }

      it "does not create a second account and explains why" do
        expect { post user_registration_path, params: params }.not_to change(User, :count)
        expect(document).to have_css("#field_user_email_error[role='alert']")
      end
    end
  end
end
