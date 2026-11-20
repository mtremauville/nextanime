require "rails_helper"

RSpec.describe Swipe, type: :model do
  it "has a valid factory" do
    expect(build(:swipe)).to be_valid
  end

  it "has a valid factory for a pass" do
    expect(build(:swipe, :passed)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:taste_profile).required }
    it { is_expected.to belong_to(:anime).required }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:liked).of_type(:boolean).with_options(null: false) }
    it { is_expected.to have_db_index([ :taste_profile_id, :anime_id ]).unique }
    it { is_expected.to have_db_index(:anime_id) }
  end

  describe "validations" do
    subject { create(:swipe) }

    it { is_expected.to validate_uniqueness_of(:anime_id).scoped_to(:taste_profile_id) }
    it "is invalid without a choice" do
      swipe = build(:swipe, liked: nil)

      expect(swipe).not_to be_valid
      expect(swipe.errors[:liked]).to be_present
    end
  end
end
