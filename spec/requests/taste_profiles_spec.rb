require "rails_helper"

RSpec.describe "Taste profile reset", type: :request do
  describe "DELETE /taste_profile/reset" do
    context "when signed in with a profile" do
      let!(:profile) { create(:taste_profile, :with_user) }

      before { sign_in profile.user }

      it "removes the swipes of the account" do
        create(:swipe, taste_profile: profile)

        expect { delete reset_taste_profile_path }.to change { profile.swipes.count }.from(1).to(0)
      end

      it "removes the recommendations of the account" do
        create(:recommendation, taste_profile: profile)

        expect { delete reset_taste_profile_path }.to change { profile.recommendations.count }.from(1).to(0)
      end

      it "keeps the watchlist" do
        entry = create(:watchlist_entry, user: profile.user)

        delete reset_taste_profile_path

        expect(WatchlistEntry.exists?(entry.id)).to be(true)
      end

      it "leaves the profiles of other people alone" do
        other_swipe = create(:swipe)

        delete reset_taste_profile_path

        expect(Swipe.exists?(other_swipe.id)).to be(true)
      end

      it "goes back to the profile page with a notice" do
        delete reset_taste_profile_path

        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to eq "Ton profil de goûts a été réinitialisé."
      end
    end

    context "when signed in without a profile yet" do
      before { sign_in create(:user) }

      it "creates no profile and goes back to the profile page" do
        expect { delete reset_taste_profile_path }.not_to change(TasteProfile, :count)

        expect(response).to redirect_to(profile_path)
      end
    end

    context "as a visitor" do
      it "asks to sign in" do
        delete reset_taste_profile_path

        expect(response).to redirect_to(new_user_session_path)
      end

      it "creates no profile and no cookie" do
        expect { delete reset_taste_profile_path }.not_to change(TasteProfile, :count)

        expect(cookies[:taste_session]).to be_nil
      end

      it "leaves alone the swipes the browser holds for the visitor" do
        post swipes_path, params: { anime_id: create(:anime).id, liked: true }

        expect { delete reset_taste_profile_path }.not_to change(Swipe, :count)
      end
    end
  end
end
