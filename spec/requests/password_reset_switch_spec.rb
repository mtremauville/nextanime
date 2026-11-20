require "rails_helper"

RSpec.describe "Switching the password reset off", type: :request do
  let(:user) { create(:user) }
  let(:new_password) { "a-long-password-123" }

  context "when the reset is on" do
    it "offers the page that asks for a link" do
      get new_user_password_path

      expect(response).to have_http_status(:ok)
    end
  end

  context "when the reset is off" do
    before { allow(Rails.configuration.x).to receive(:password_reset_enabled).and_return(false) }

    it "answers not found to the page that asks for a link" do
      get new_user_password_path

      expect(response).to have_http_status(:not_found)
    end

    it "answers not found to the page that chooses a new password" do
      get edit_user_password_path(reset_password_token: "token")

      expect(response).to have_http_status(:not_found)
    end

    it "sends no e-mail and answers not found to a request for a link" do
      expect { post user_password_path, params: { user: { email: user.email } } }
        .not_to change { ActionMailer::Base.deliveries.count }

      expect(response).to have_http_status(:not_found)
    end

    it "answers not found to the choice of a new password" do
      patch user_password_path,
            params: { user: { reset_password_token: "token", password: new_password, password_confirmation: new_password } }

      expect(response).to have_http_status(:not_found)
    end
  end
end
