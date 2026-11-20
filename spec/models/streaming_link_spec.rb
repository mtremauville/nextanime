require "rails_helper"

RSpec.describe StreamingLink, type: :model do
  subject(:streaming_link) { build(:streaming_link) }

  it "has a valid factory" do
    expect(streaming_link).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:anime) }
    it { is_expected.to belong_to(:streaming_platform) }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:url).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:language).of_type(:string) }
    it { is_expected.to have_db_index(%i[anime_id url]).unique(true) }
    it { is_expected.to have_db_index(:streaming_platform_id) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_uniqueness_of(:url).scoped_to(:anime_id) }
  end
end
