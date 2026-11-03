require "rails_helper"

RSpec.describe "Account deletion", type: :request do
  describe "DELETE /users" do
    context "as a visitor" do
      it "asks to sign in and deletes nothing" do
        create(:user)

        expect { delete user_registration_path }.not_to change(User, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      let(:user) { create(:user) }
      let(:profile) { create(:taste_profile, :with_user, user: user) }
      let(:anime) { create(:anime) }

      before do
        create(:swipe, taste_profile: profile, anime: anime)
        create(:recommendation, taste_profile: profile, anime: anime)
        create(:watchlist_entry, user: user, anime: anime)
        sign_in user
      end

      it "removes the account" do
        expect { delete user_registration_path }.to change(User, :count).by(-1)
        expect(User.exists?(user.id)).to be(false)
      end

      it "removes everything that belongs to the account" do
        delete user_registration_path

        expect([ TasteProfile.count, Swipe.count, Recommendation.count, WatchlistEntry.count ]).to eq([ 0, 0, 0, 0 ])
      end

      it "keeps the anime catalog" do
        expect { delete user_registration_path }.not_to change(Anime, :count)
      end

      it "leaves the data of other accounts alone" do
        other = create(:user)
        other_profile = create(:taste_profile, :with_user, user: other)
        create(:swipe, taste_profile: other_profile)
        create(:watchlist_entry, user: other)

        delete user_registration_path

        expect(User.exists?(other.id)).to be(true)
        expect(other_profile.swipes.count).to eq(1)
        expect(other.watchlist_entries.count).to eq(1)
      end

      it "signs the user out" do
        delete user_registration_path
        get profile_path

        expect(response).to redirect_to(new_user_session_path)
      end

      it "goes back to the home page with a notice" do
        delete user_registration_path

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(Capybara.string(response.body)).to have_text("Ton compte et tes données ont été supprimés. À bientôt !")
      end
    end
  end
end
