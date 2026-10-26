require "rails_helper"

RSpec.describe "Sign up", type: :request do
  let(:document) { Capybara.string(response.body) }
  let(:password) { "correct-horse-battery" }
  let(:privacy_policy) { "1" }
  let(:params) do
    {
      user: {
        email: "new@example.com",
        password: password,
        password_confirmation: password,
        privacy_policy: privacy_policy
      }
    }
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
    end

    context "when the privacy policy field is missing" do
      it "does not create the account" do
        params[:user].delete(:privacy_policy)

        expect { post user_registration_path, params: params }.not_to change(User, :count)
      end
    end
  end
end
