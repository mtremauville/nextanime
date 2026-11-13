require "rails_helper"

RSpec.describe StreamingPlatform, type: :model do
  subject(:platform) { build(:streaming_platform) }

  it "has a valid factory" do
    expect(platform).to be_valid
  end

  describe "associations" do
    it { is_expected.to have_many(:streaming_links).dependent(:destroy) }
    it { is_expected.to have_many(:streaming_availabilities).dependent(:destroy) }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:slug).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:name).unique(true) }
    it { is_expected.to have_db_index(:slug).unique(true) }
    it { is_expected.to have_db_column(:tmdb_provider_id).of_type(:integer) }
    it { is_expected.to have_db_index(:tmdb_provider_id).unique(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:tmdb_provider_id).allow_nil }
  end
end
