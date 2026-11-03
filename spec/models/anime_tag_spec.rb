require "rails_helper"

RSpec.describe AnimeTag, type: :model do
  subject(:anime_tag) { build(:anime_tag) }

  it "has a valid factory" do
    expect(anime_tag).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:anime) }
    it { is_expected.to belong_to(:tag) }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:rank).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_index(%i[anime_id tag_id]).unique(true) }
    it { is_expected.to have_db_index(:tag_id) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:tag_id).scoped_to(:anime_id) }

    it do
      expect(anime_tag).to validate_numericality_of(:rank)
        .only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100)
    end
  end
end
