require "rails_helper"

RSpec.describe "Adding an anime to the watchlist", type: :request do
  let(:anime) { create(:anime) }

  context "when a member is signed in" do
    let(:member) { create(:user) }

    before { sign_in member }

    it "puts the anime in their watchlist, still to watch" do
      expect { post anime_watchlist_entry_path(anime) }.to change { member.watchlist_entries.count }.by(1)

      entry = member.watchlist_entries.find_by!(anime: anime)
      expect(entry).to be_plan_to_watch
      expect(entry.progress).to eq(0)
    end

    it "goes back to the page of the anime with a confirmation" do
      post anime_watchlist_entry_path(anime)

      expect(response).to redirect_to(anime_path(anime))
      expect(flash[:notice]).to eq(I18n.t("watchlist_entries.create.added"))
    end

    it "does not add the anime twice, and keeps the progress already made" do
      entry = create(:watchlist_entry, :watching, user: member, anime: anime)

      expect { post anime_watchlist_entry_path(anime) }.not_to change(WatchlistEntry, :count)

      expect(response).to redirect_to(anime_path(anime))
      expect(entry.reload).to be_watching
      expect(entry.progress).to eq(3)
    end

    it "ignores a status or a progress sent with the request" do
      post anime_watchlist_entry_path(anime), params: { watchlist_entry: { status: "completed", progress: 99 } }

      entry = member.watchlist_entries.find_by!(anime: anime)
      expect(entry).to be_plan_to_watch
      expect(entry.progress).to eq(0)
    end

    it "answers not found for an anime that does not exist" do
      post anime_watchlist_entry_path(anime_id: 0)

      expect(response).to have_http_status(:not_found)
    end
  end

  context "when nobody is signed in" do
    it "sends the visitor to the sign in page and adds nothing" do
      expect { post anime_watchlist_entry_path(anime) }.not_to change(WatchlistEntry, :count)

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
