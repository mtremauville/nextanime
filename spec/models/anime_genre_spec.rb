require "rails_helper"

RSpec.describe AnimeGenre, type: :model do
  subject(:anime_genre) { build(:anime_genre) }

  it "has a valid factory" do
    expect(anime_genre).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:anime) }
    it { is_expected.to belong_to(:genre) }
  end

  describe "columns" do
    it { is_expected.to have_db_index(%i[anime_id genre_id]).unique(true) }
    it { is_expected.to have_db_index(:genre_id) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:genre_id).scoped_to(:anime_id) }
  end
end
