require "rails_helper"

RSpec.describe "Account settings", type: :request do
  let(:password) { "a-long-password-123" }
  let(:new_password) { "another-long-password-456" }
  let(:user) { create(:user, email: "me@example.com", password: password, password_confirmation: password) }

  def update_account(attributes = {})
    patch profile_path, params: {
      user: { email: user.email, password: "", current_password: password }.merge(attributes)
    }
  end

  shared_examples "a refused update" do
    it "answers unprocessable and changes nothing" do
      expect(response).to have_http_status(:unprocessable_content)
      expect(user.reload.email).to eq("me@example.com")
      expect(user.valid_password?(password)).to be(true)
    end
  end

  context "as a visitor" do
    it "asks to sign in" do
      patch profile_path, params: { user: { email: "new@example.com", current_password: password } }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when signed in" do
    before { sign_in user }

    it "changes the e-mail address" do
      update_account(email: "new@example.com")

      expect(user.reload.email).to eq("new@example.com")
    end

    it "goes back to the profile page with a notice" do
      update_account(email: "new@example.com")

      expect(response).to redirect_to(profile_path)
      expect(flash[:notice]).to eq("Tes informations ont été mises à jour.")
    end

    it "changes the password" do
      update_account(password: new_password)

      expect(user.reload.valid_password?(new_password)).to be(true)
    end

    it "keeps the user signed in after a new password" do
      update_account(password: new_password)
      get profile_path

      expect(user.reload.valid_password?(new_password)).to be(true)
      expect(response).to have_http_status(:ok)
    end

    it "keeps the password when no new one is given" do
      update_account(email: "new@example.com")

      expect(user.reload.email).to eq("new@example.com")
      expect(user.valid_password?(password)).to be(true)
    end

    it "ignores the attributes the form does not offer" do
      update_account(email: "new@example.com", username: "hacker")

      expect(user.reload.email).to eq("new@example.com")
      expect(user.username).not_to eq("hacker")
    end

    context "with a wrong current password" do
      before { update_account(email: "new@example.com", current_password: "wrong-password-123") }

      it_behaves_like "a refused update"

      it "shows the profile page again" do
        expect(Capybara.string(response.body)).to have_css("[data-stat='swipes']")
      end

      it "keeps the saved e-mail address in the header" do
        document = Capybara.string(response.body)

        expect(document).to have_css(".na-profile-header", text: "me@example.com")
        expect(document).to have_no_css(".na-profile-header", text: "new@example.com")
      end
    end

    context "without the current password" do
      before { update_account(email: "new@example.com", current_password: "") }

      it_behaves_like "a refused update"
    end

    context "with an invalid e-mail address" do
      before { update_account(email: "not-an-email") }

      it_behaves_like "a refused update"
    end

    context "with a new password that is too short" do
      before { update_account(password: "short") }

      it_behaves_like "a refused update"
    end

    context "with an e-mail address already used" do
      before do
        create(:user, email: "taken@example.com")
        update_account(email: "taken@example.com")
      end

      it_behaves_like "a refused update"
    end
  end
end
