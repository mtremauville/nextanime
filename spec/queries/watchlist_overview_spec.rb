require "rails_helper"

RSpec.describe WatchlistOverview do
  let(:user) { create(:user) }
  let(:overview) { described_class.new(WatchlistEntry.where(user: user)) }

  def add_entry(*traits, progress: nil, episodes: 12, **attributes)
    anime = create(:anime, episodes: episodes)
    entry_attributes = { user: user, anime: anime, **attributes }
    entry_attributes[:progress] = progress if progress
    create(:watchlist_entry, *traits, **entry_attributes)
  end

  describe "#counts" do
    it "counts the entries of each status, zero included" do
      add_entry
      add_entry(:watching)
      add_entry(:watching)

      expect(overview.counts).to eq("plan_to_watch" => 1, "watching" => 2, "completed" => 0)
    end

    it "ignores the entries of other members" do
      create(:watchlist_entry)

      expect(overview.counts.values).to all(eq(0))
    end
  end

  describe "#total" do
    it "counts every entry whatever its status" do
      add_entry
      add_entry(:watching)
      add_entry(:completed)

      expect(overview.total).to eq(3)
    end
  end

  describe "#global_percent" do
    it "is the share of episodes watched across the whole watchlist" do
      add_entry(:watching, progress: 14, episodes: 28)
      add_entry(:completed, progress: 12, episodes: 12)

      expect(overview.global_percent).to eq(65)
    end

    it "leaves out the anime whose episode count is unknown" do
      add_entry(:watching, progress: 14, episodes: 28)
      add_entry(:watching, progress: 5, episodes: nil)

      expect(overview.global_percent).to eq(50)
    end

    it "is unknown while no anime has an episode count" do
      add_entry(:watching, progress: 5, episodes: nil)

      expect(overview.global_percent).to be_nil
    end
  end

  describe "#resume_entry" do
    it "is the entry being watched that was updated last" do
      add_entry(:watching, updated_at: 3.days.ago)
      latest = add_entry(:watching, updated_at: 1.day.ago)
      add_entry(:completed, updated_at: 1.hour.ago)

      expect(overview.resume_entry).to eq(latest)
    end

    it "is nil when nothing is being watched" do
      add_entry(:completed)

      expect(overview.resume_entry).to be_nil
    end
  end
end
