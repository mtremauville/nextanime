require "rails_helper"

RSpec.describe Studio, type: :model do
  subject(:studio) { build(:studio) }

  it "has a valid factory" do
    expect(studio).to be_valid
  end

  describe "columns" do
    it { is_expected.to have_db_column(:anilist_studio_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:anilist_studio_id).unique(true) }
    it { is_expected.to have_db_index(:name).unique(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:anilist_studio_id) }
    it { is_expected.to validate_uniqueness_of(:anilist_studio_id) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
