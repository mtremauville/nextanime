require "rails_helper"

RSpec.describe "Password reset", type: :request do
  let!(:user) { create(:user, password: "old password is long enough") }
  let(:new_password) { "brand new password is long" }

  def sent_mails
    ActionMailer::Base.deliveries
  end

  def token_from_last_mail
    sent_mails.last.body.decoded[/reset_password_token=([^"&\s]+)/, 1]
  end

  before { sent_mails.clear }

  describe "POST /users/password" do
    context "with the e-mail address of an account" do
      before { post user_password_path, params: { user: { email: user.email } } }

      it "sends one e-mail to the account" do
        expect(sent_mails.size).to eq(1)
        expect(sent_mails.last.to).to eq([ user.email ])
      end

      it "goes back to the sign in page with a notice" do
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:notice]).to be_present
      end
    end

    context "with an unknown e-mail address" do
      before { post user_password_path, params: { user: { email: "nobody@example.com" } } }

      it "sends no e-mail" do
        expect(sent_mails).to be_empty
      end

      it "gives the exact same answer as for an existing account" do
        notice = flash[:notice]
        location = response.location

        post user_password_path, params: { user: { email: user.email } }

        expect(response.location).to eq(location)
        expect(flash[:notice]).to eq(notice)
      end
    end

    context "with a blank e-mail address" do
      it "sends no e-mail" do
        post user_password_path, params: { user: { email: "" } }

        expect(sent_mails).to be_empty
      end
    end
  end

  describe "PATCH /users/password" do
    before { post user_password_path, params: { user: { email: user.email } } }

    def update_password(token:, password: new_password, confirmation: password)
      patch user_password_path, params: { user: {
        reset_password_token: token,
        password: password,
        password_confirmation: confirmation
      } }
    end

    it "changes the password with the token received by e-mail and signs in" do
      update_password(token: token_from_last_mail)

      expect(user.reload.valid_password?(new_password)).to be(true)
      expect(response).to redirect_to(root_path)
    end

    it "refuses a token that is not valid" do
      update_password(token: "not-a-token")

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.valid_password?(new_password)).to be(false)
    end

    it "refuses an expired token" do
      token = token_from_last_mail

      travel_to(3.hours.from_now) { update_password(token: token) }

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.valid_password?(new_password)).to be(false)
    end

    it "refuses a password that is too short" do
      update_password(token: token_from_last_mail, password: "short")

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.valid_password?("short")).to be(false)
    end

    it "refuses passwords that differ" do
      update_password(token: token_from_last_mail, confirmation: "another password is long")

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.valid_password?(new_password)).to be(false)
    end

    it "keeps the token usable after a refused attempt" do
      token = token_from_last_mail
      update_password(token: token, password: "short")
      update_password(token: token)

      expect(user.reload.valid_password?(new_password)).to be(true)
    end
  end
end
