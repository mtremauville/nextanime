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

      it "goes back to the swipe page with a notice" do
        delete reset_taste_profile_path

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq "Ton profil de goûts a été réinitialisé."
      end
    end

    context "when signed in without a profile yet" do
      before { sign_in create(:user) }

      it "creates no profile and goes back to the swipe page" do
        expect { delete reset_taste_profile_path }.not_to change(TasteProfile, :count)

        expect(response).to redirect_to(root_path)
      end
    end

    context "as a visitor without a profile" do
      it "creates no profile and no cookie" do
        expect { delete reset_taste_profile_path }.not_to change(TasteProfile, :count)

        expect(response).to redirect_to(root_path)
        expect(cookies[:taste_session]).to be_nil
      end
    end
  end
end

RSpec.describe "Taste profile reset for a visitor", type: :request do
  describe "DELETE /taste_profile/reset" do
    context "after swiping" do
      let(:anime) { create(:anime) }
      let(:profile) { TasteProfile.last }

      before { post swipes_path, params: { anime_id: anime.id, liked: true } }

      it "removes the swipes of the visitor" do
        expect { delete reset_taste_profile_path }.to change { profile.swipes.count }.from(1).to(0)
      end

      it "keeps the profile" do
        expect { delete reset_taste_profile_path }.not_to change(TasteProfile, :count)
      end

      it "keeps the cookie that opens the profile" do
        expect { delete reset_taste_profile_path }.not_to change { cookies[:taste_session] }
      end

      it "lets the visitor swipe the same anime again" do
        delete reset_taste_profile_path

        expect { post swipes_path, params: { anime_id: anime.id, liked: false } }
          .to change { profile.swipes.count }.from(0).to(1)
      end

      it "goes back to the swipe page with a notice" do
        delete reset_taste_profile_path

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq "Ton profil de goûts a été réinitialisé."
      end
    end

    context "with a cookie that is not signed" do
      it "does not reset the profile of the token it carries" do
        other_swipe = create(:swipe)
        cookies[:taste_session] = other_swipe.taste_profile.session_token

        delete reset_taste_profile_path

        expect(Swipe.exists?(other_swipe.id)).to be(true)
      end
    end
  end
end
