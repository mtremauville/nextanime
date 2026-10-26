require "rails_helper"

RSpec.describe Genre, type: :model do
  subject(:genre) { build(:genre) }

  it "has a valid factory" do
    expect(genre).to be_valid
  end

  describe "associations" do
    it { is_expected.to have_many(:anime_genres).dependent(:destroy) }
    it { is_expected.to have_many(:animes).through(:anime_genres) }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:name).unique(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
