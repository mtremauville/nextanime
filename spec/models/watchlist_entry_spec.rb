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
end
