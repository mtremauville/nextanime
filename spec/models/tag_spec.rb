require "rails_helper"

RSpec.describe Tag, type: :model do
  subject(:tag) { build(:tag) }

  it "has a valid factory" do
    expect(tag).to be_valid
  end

  describe "columns" do
    it { is_expected.to have_db_column(:anilist_tag_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:adult).of_type(:boolean).with_options(null: false, default: false) }
    it { is_expected.to have_db_index(:anilist_tag_id).unique(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:anilist_tag_id) }
    it { is_expected.to validate_uniqueness_of(:anilist_tag_id) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe ".not_adult" do
    it "excludes the adult tags" do
      safe_tag = create(:tag)
      create(:tag, adult: true)

      expect(described_class.not_adult).to contain_exactly(safe_tag)
    end
  end
end
