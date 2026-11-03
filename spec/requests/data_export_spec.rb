require "rails_helper"

RSpec.describe "Personal data export", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  describe "GET /profil/export" do
    context "as a visitor" do
      it "asks to sign in" do
        get data_export_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "answers with a JSON file" do
        get data_export_path

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("application/json")
      end

      it "offers the file as a download named after the day" do
        travel_to(Time.zone.local(2026, 11, 3, 15, 0)) { get data_export_path }

        expect(response.headers["Content-Disposition"]).to start_with("attachment")
        expect(response.headers["Content-Disposition"]).to include('filename="nextanime-donnees-2026-11-03.json"')
      end

      it "is never kept in a cache" do
        get data_export_path

        expect(response.headers["Cache-Control"]).to include("no-store")
      end

      it "holds the account, the swipes and the watchlist" do
        create(:swipe, taste_profile: create(:taste_profile, :with_user, user: user))
        create(:watchlist_entry, user: user)

        get data_export_path
        data = response.parsed_body

        expect(data["account"]["email"]).to eq(user.email)
        expect(data["swipes"].size).to eq(1)
        expect(data["watchlist"].size).to eq(1)
      end

      it "never holds the password" do
        get data_export_path

        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include(user.encrypted_password)
      end

      it "leaves out the data of other accounts" do
        other = create(:user)
        create(:swipe, taste_profile: create(:taste_profile, :with_user, user: other))
        create(:watchlist_entry, user: other)

        get data_export_path
        data = response.parsed_body

        expect(response.body).not_to include(other.email)
        expect(data["swipes"]).to eq([])
        expect(data["watchlist"]).to eq([])
      end

      it "creates no taste profile just by exporting" do
        expect { get data_export_path }.not_to change(TasteProfile, :count)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
