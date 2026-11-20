require "rails_helper"

RSpec.describe TmdbMatch, type: :model do
  subject(:tmdb_match) { build(:tmdb_match) }

  it "has a valid factory" do
    expect(tmdb_match).to be_valid
  end

  it "accepts an anime that could not be matched" do
    expect(build(:tmdb_match, :unmatched)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:anime) }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:tmdb_id).of_type(:integer) }
    it { is_expected.to have_db_column(:media_type).of_type(:string) }
    it { is_expected.to have_db_column(:checked_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_index(:anime_id).unique(true) }
  end

  describe "media types" do
    it do
      expect(tmdb_match).to define_enum_for(:media_type)
        .with_values(tv: "tv", movie: "movie")
        .backed_by_column_of_type(:string)
        .with_prefix(:media)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:checked_at) }
    it { is_expected.to validate_uniqueness_of(:anime_id) }

    it "rejects a TMDB id without media type" do
      expect(build(:tmdb_match, media_type: nil)).not_to be_valid
    end

    it "rejects a media type without TMDB id" do
      expect(build(:tmdb_match, tmdb_id: nil)).not_to be_valid
    end
  end

  describe "database constraints" do
    it "also requires the TMDB id and the media type together when validations are skipped" do
      half_match = build(:tmdb_match, tmdb_id: nil)

      expect { half_match.save!(validate: false) }
        .to raise_error(ActiveRecord::StatementInvalid, /tmdb_matches_id_and_media_type_together/)
    end
  end

  describe "scopes" do
    let!(:matched_one) { create(:tmdb_match) }
    let!(:unmatched_one) { create(:tmdb_match, :unmatched) }

    it "lists the anime that were matched" do
      expect(described_class.matched).to contain_exactly(matched_one)
    end

    it "lists the anime that could not be matched" do
      expect(described_class.unmatched).to contain_exactly(unmatched_one)
    end
  end

  describe "#matched?" do
    it "is true when a TMDB title was found" do
      expect(build(:tmdb_match)).to be_matched
    end

    it "is false when no TMDB title was found" do
      expect(build(:tmdb_match, :unmatched)).not_to be_matched
    end
  end
end
