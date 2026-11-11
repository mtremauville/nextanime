require "rails_helper"

RSpec.describe WatchlistEntryPolicy, type: :policy do
  let(:anime) { create(:anime) }

  describe "#create?" do
    it "lets a member put an anime in their own watchlist" do
      member = create(:user)
      entry = member.watchlist_entries.build(anime: anime)

      expect(described_class.new(member, entry).create?).to be(true)
    end

    it "refuses a visitor" do
      entry = WatchlistEntry.new(anime: anime)

      expect(described_class.new(nil, entry).create?).to be(false)
    end

    it "refuses to fill the watchlist of someone else" do
      member = create(:user)
      entry = create(:user).watchlist_entries.build(anime: anime)

      expect(described_class.new(member, entry).create?).to be(false)
    end
  end
end
