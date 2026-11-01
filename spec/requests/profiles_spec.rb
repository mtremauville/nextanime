require "rails_helper"

RSpec.describe "Profile page", type: :request do
  describe "GET /profil" do
    context "as a visitor" do
      it "asks to sign in" do
        get profile_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      before { sign_in create(:user) }

      it "succeeds" do
        get profile_path

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
