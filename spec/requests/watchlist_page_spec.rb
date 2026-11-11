require "rails_helper"

RSpec.describe "The watchlist page", type: :request do
  context "when nobody is signed in" do
    it "sends the visitor to the sign in page" do
      get watchlist_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when a member is signed in" do
    before { sign_in create(:user) }

    it "shows the page" do
      get watchlist_path

      expect(response).to have_http_status(:ok)
    end

    it "ignores a status that does not exist" do
      get watchlist_path, params: { status: "dropped" }

      expect(response).to have_http_status(:ok)
    end
  end
end
