require "rails_helper"

RSpec.describe "Attaching the guest profile at sign up", type: :request do
  let(:anime) { create(:anime) }
  let(:email) { "new@example.com" }
  let(:password) { "a-long-password-123" }

  def sign_up(password: self.password)
    post user_registration_path, params: {
      user: { email: email, password: password, password_confirmation: password, privacy_policy: "1" }
    }
  end

  def new_user
    User.find_by!(email: email)
  end

  context "when the visitor swiped before signing up" do
    before { post swipes_path, params: { anime_id: anime.id, liked: true } }

    it "gives the swipes to the new account" do
      sign_up

      expect(new_user.taste_profile.swiped_anime_ids).to eq([ anime.id ])
    end

    it "forgets the guest cookie once the profile belongs to the account" do
      sign_up

      expect(cookies[:taste_session]).to be_blank
    end

    it "keeps the guest profile and its cookie when the sign up is refused" do
      sign_up(password: "short")

      expect(User.find_by(email: email)).to be_nil
      expect(TasteProfile.where.not(session_token: nil).count).to eq(1)
      expect(cookies[:taste_session]).to be_present
    end
  end

  context "when the visitor never swiped" do
    it "creates the account without any profile" do
      sign_up

      expect(new_user.taste_profile).to be_nil
    end
  end

  context "with a cookie that points to somebody else's profile" do
    it "leaves that profile alone" do
      other = TasteProfile.for_session("someone-else")
      cookies[:taste_session] = "someone-else"

      sign_up

      expect(other.reload.user).to be_nil
      expect(new_user.taste_profile).to be_nil
    end
  end
end
