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

  describe WatchlistEntryPolicy::Scope do
    it "returns only the entries of the signed-in member" do
      member = create(:user)
      own_entry = create(:watchlist_entry, user: member)
      create(:watchlist_entry)

      expect(described_class.new(member, WatchlistEntry).resolve).to contain_exactly(own_entry)
    end

    it "returns nothing for a visitor" do
      create(:watchlist_entry)

      expect(described_class.new(nil, WatchlistEntry).resolve).to be_empty
    end
  end

  describe "#update?" do
    let(:member) { create(:user) }
    let(:entry) { build(:watchlist_entry, user: member) }

    it "lets a member change the progress of their own entry" do
      expect(described_class.new(member, entry)).to be_update
    end

    it "refuses a visitor" do
      expect(described_class.new(nil, entry)).not_to be_update
    end

    it "refuses to change the progress of the entry of someone else" do
      expect(described_class.new(create(:user), entry)).not_to be_update
    end
  end
end
