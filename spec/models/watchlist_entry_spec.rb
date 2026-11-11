require "rails_helper"

RSpec.describe WatchlistEntry, type: :model do
  it "has a valid factory" do
    expect(build(:watchlist_entry)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:user).required }
    it { is_expected.to belong_to(:anime).required }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:status).of_type(:integer).with_options(null: false, default: "plan_to_watch") }
    it { is_expected.to have_db_column(:progress).of_type(:integer).with_options(null: false, default: 0) }
    it { is_expected.to have_db_index([ :user_id, :anime_id ]).unique }
    it { is_expected.to have_db_index([ :user_id, :status ]) }
    it { is_expected.to have_db_index(:anime_id) }
  end

  describe "validations" do
    subject { create(:watchlist_entry) }

    it { is_expected.to validate_uniqueness_of(:anime_id).scoped_to(:user_id) }
    it { is_expected.to validate_numericality_of(:progress).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe "status" do
    it do
      expect(described_class.new).to define_enum_for(:status)
        .with_values(plan_to_watch: 0, watching: 1, completed: 2)
        .backed_by_column_of_type(:integer)
    end

    it "starts as plan to watch" do
      expect(described_class.new).to be_plan_to_watch
    end

    it "starts with no episode watched" do
      expect(described_class.new.progress).to eq(0)
    end

    it "is invalid, instead of raising, for an unknown status" do
      entry = build(:watchlist_entry, status: "dropped")

      expect(entry).not_to be_valid
      expect(entry.errors[:status]).to be_present
    end
  end

  describe "#total_episodes" do
    it "is the episode count of the anime" do
      entry = build(:watchlist_entry, anime: build(:anime, episodes: 28))

      expect(entry.total_episodes).to eq(28)
    end
  end

  describe "#percent" do
    def entry_with(progress:, episodes:)
      build(:watchlist_entry, progress: progress, anime: build(:anime, episodes: episodes))
    end

    it "is the share of episodes watched" do
      expect(entry_with(progress: 14, episodes: 28).percent).to eq(50)
    end

    it "is rounded to the nearest whole number" do
      expect(entry_with(progress: 1, episodes: 3).percent).to eq(33)
    end

    it "never goes above 100" do
      expect(entry_with(progress: 30, episodes: 28).percent).to eq(100)
    end

    it "is unknown while the anime has no episode count" do
      expect(entry_with(progress: 5, episodes: nil).percent).to be_nil
    end
  end

  describe "moving the progress" do
    def entry_at(progress:, episodes: 12, status: "watching")
      create(:watchlist_entry, status: status, progress: progress, anime: create(:anime, episodes: episodes))
    end

    describe "#fully_watched?" do
      it "is true once every episode is watched" do
        expect(entry_at(progress: 12)).to be_fully_watched
      end

      it "is false before the last episode" do
        expect(entry_at(progress: 11)).not_to be_fully_watched
      end

      it "is false while the episode count is unknown" do
        expect(entry_at(progress: 5, episodes: nil)).not_to be_fully_watched
      end
    end

    describe "#advance" do
      it "watches one more episode" do
        entry = entry_at(progress: 3)

        entry.advance

        expect(entry.reload).to have_attributes(progress: 4, status: "watching")
      end

      it "starts watching what was still to watch" do
        entry = entry_at(progress: 0, status: "plan_to_watch")

        entry.advance

        expect(entry.reload).to have_attributes(progress: 1, status: "watching")
      end

      it "completes the anime on its last episode" do
        entry = entry_at(progress: 11)

        entry.advance

        expect(entry.reload).to have_attributes(progress: 12, status: "completed")
      end

      it "stays on the last episode" do
        entry = entry_at(progress: 12, status: "completed")

        entry.advance

        expect(entry.reload).to have_attributes(progress: 12, status: "completed")
      end

      it "never completes an anime whose episode count is unknown" do
        entry = entry_at(progress: 5, episodes: nil)

        entry.advance

        expect(entry.reload).to have_attributes(progress: 6, status: "watching")
      end
    end

    describe "#rewind" do
      it "watches one episode less" do
        entry = entry_at(progress: 4)

        entry.rewind

        expect(entry.reload).to have_attributes(progress: 3, status: "watching")
      end

      it "reopens a completed anime" do
        entry = entry_at(progress: 12, status: "completed")

        entry.rewind

        expect(entry.reload).to have_attributes(progress: 11, status: "watching")
      end

      it "goes back to still to watch at the first episode" do
        entry = entry_at(progress: 1)

        entry.rewind

        expect(entry.reload).to have_attributes(progress: 0, status: "plan_to_watch")
      end

      it "stays at zero" do
        entry = entry_at(progress: 0, status: "plan_to_watch")

        entry.rewind

        expect(entry.reload).to have_attributes(progress: 0, status: "plan_to_watch")
      end
    end
  end
end
