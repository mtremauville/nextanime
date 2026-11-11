require "rails_helper"

RSpec.describe "Moving the progress of a watchlist entry", type: :request do
  let(:member) { create(:user) }
  let(:entry) { create(:watchlist_entry, :watching, user: member, progress: 3, anime: create(:anime, episodes: 12)) }

  context "when a member is signed in" do
    before { sign_in member }

    it "watches one more episode" do
      patch watchlist_entry_path(entry), params: { move: "advance" }

      expect(entry.reload.progress).to eq(4)
    end

    it "watches one episode less" do
      patch watchlist_entry_path(entry), params: { move: "rewind" }

      expect(entry.reload.progress).to eq(2)
    end

    it "completes the anime on its last episode" do
      last = create(:watchlist_entry, :watching, user: member, progress: 11, anime: create(:anime, episodes: 12))

      patch watchlist_entry_path(last), params: { move: "advance" }

      expect(last.reload).to be_completed
    end

    it "goes back to the watchlist" do
      patch watchlist_entry_path(entry), params: { move: "advance" }

      expect(response).to redirect_to(watchlist_path)
      expect(response).to have_http_status(:see_other)
    end

    it "keeps the status filter" do
      patch watchlist_entry_path(entry, status: "watching"), params: { move: "advance" }

      expect(response).to redirect_to(watchlist_path(status: "watching"))
    end

    it "drops a status filter that does not exist" do
      patch watchlist_entry_path(entry, status: "dropped"), params: { move: "advance" }

      expect(response).to redirect_to(watchlist_path)
    end

    it "refuses a move that does not exist" do
      patch watchlist_entry_path(entry), params: { move: "skip" }

      expect(response).to have_http_status(:bad_request)
      expect(entry.reload.progress).to eq(3)
    end

    it "refuses a request without a move" do
      patch watchlist_entry_path(entry)

      expect(response).to have_http_status(:bad_request)
      expect(entry.reload.progress).to eq(3)
    end

    it "does not touch the entry of another member" do
      other_entry = create(:watchlist_entry, :watching, progress: 3)

      patch watchlist_entry_path(other_entry), params: { move: "advance" }

      expect(response).to have_http_status(:not_found)
      expect(other_entry.reload.progress).to eq(3)
    end
  end

  context "when nobody is signed in" do
    it "sends the visitor to the sign in page and changes nothing" do
      patch watchlist_entry_path(entry), params: { move: "advance" }

      expect(response).to redirect_to(new_user_session_path)
      expect(entry.reload.progress).to eq(3)
    end
  end
end
