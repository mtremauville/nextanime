require "rails_helper"

RSpec.describe "Removing an entry from the watchlist", type: :request do
  let(:member) { create(:user) }
  let!(:entry) { create(:watchlist_entry, :watching, user: member, progress: 3) }

  context "when a member is signed in" do
    before { sign_in member }

    it "removes the entry" do
      expect { delete watchlist_entry_path(entry) }.to change(WatchlistEntry, :count).by(-1)
      expect(WatchlistEntry.exists?(entry.id)).to be(false)
    end

    it "keeps the anime and the member" do
      expect { delete watchlist_entry_path(entry) }.not_to change { [ Anime.count, User.count ] }
    end

    it "goes back to the watchlist" do
      delete watchlist_entry_path(entry)

      expect(response).to redirect_to(watchlist_path)
      expect(response).to have_http_status(:see_other)
    end

    it "keeps the status filter" do
      delete watchlist_entry_path(entry, status: "watching")

      expect(response).to redirect_to(watchlist_path(status: "watching"))
    end

    it "drops a status filter that does not exist" do
      delete watchlist_entry_path(entry, status: "dropped")

      expect(response).to redirect_to(watchlist_path)
    end

    it "does not touch the entry of another member" do
      other_entry = create(:watchlist_entry, :watching)

      delete watchlist_entry_path(other_entry)

      expect(response).to have_http_status(:not_found)
      expect(WatchlistEntry.exists?(other_entry.id)).to be(true)
    end
  end

  context "when nobody is signed in" do
    it "sends the visitor to the sign in page and removes nothing" do
      delete watchlist_entry_path(entry)

      expect(response).to redirect_to(new_user_session_path)
      expect(WatchlistEntry.exists?(entry.id)).to be(true)
    end
  end

  describe "the confirmation" do
    it "tells which anime was removed" do
      sign_in member
      frieren = create(:anime, title_romaji: "Sousou no Frieren", title_english: "Frieren")
      titled = create(:watchlist_entry, user: member, anime: frieren)

      delete watchlist_entry_path(titled)

      expect(flash[:notice]).to eq("Frieren a été retiré de ta watchlist.")
    end
  end
end
