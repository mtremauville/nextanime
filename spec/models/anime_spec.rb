require "rails_helper"

RSpec.describe Anime, type: :model do
  subject(:anime) { build(:anime) }

  it "has a valid factory" do
    expect(anime).to be_valid
  end

  describe "columns" do
    it { is_expected.to have_db_column(:anilist_id).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:title_romaji).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:next_airing_at).of_type(:datetime) }
    it { is_expected.to have_db_index(:anilist_id).unique(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:anilist_id) }
    it { is_expected.to validate_uniqueness_of(:anilist_id) }
    it { is_expected.to validate_presence_of(:title_romaji) }

    it do
      expect(anime).to validate_numericality_of(:average_score)
        .only_integer.is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100).allow_nil
    end

    it { is_expected.to validate_numericality_of(:episodes).only_integer.is_greater_than(0).allow_nil }
    it { is_expected.to validate_numericality_of(:duration).only_integer.is_greater_than(0).allow_nil }
  end

  describe "enums" do
    it do
      expect(anime).to define_enum_for(:format)
        .with_values(tv: "TV", tv_short: "TV_SHORT", movie: "MOVIE", special: "SPECIAL",
                     ova: "OVA", ona: "ONA", music: "MUSIC")
        .backed_by_column_of_type(:string)
        .with_prefix
    end

    it do
      expect(anime).to define_enum_for(:airing_status)
        .with_values(finished: "FINISHED", releasing: "RELEASING", not_yet_released: "NOT_YET_RELEASED",
                     cancelled: "CANCELLED", hiatus: "HIATUS")
        .backed_by_column_of_type(:string)
        .with_prefix(:airing)
    end

    it do
      expect(anime).to define_enum_for(:season)
        .with_values(winter: "WINTER", spring: "SPRING", summer: "SUMMER", fall: "FALL")
        .backed_by_column_of_type(:string)
        .with_prefix
    end

    it "is invalid, instead of raising, for a value AniList may add later" do
      anime.format = "MANGA"

      expect(anime).not_to be_valid
    end

    it "accepts the raw AniList value" do
      anime.airing_status = "NOT_YET_RELEASED"

      expect(anime).to be_airing_not_yet_released
    end
  end

  describe "#display_title" do
    it "prefers the English title" do
      anime = build(:anime, title_romaji: "Shingeki no Kyojin", title_english: "Attack on Titan")

      expect(anime.display_title).to eq("Attack on Titan")
    end

    it "falls back to the romaji title when there is no English title" do
      anime = build(:anime, title_romaji: "Shingeki no Kyojin", title_english: nil)

      expect(anime.display_title).to eq("Shingeki no Kyojin")
    end

    it "falls back to the romaji title when the English title is blank" do
      anime = build(:anime, title_romaji: "Shingeki no Kyojin", title_english: "")

      expect(anime.display_title).to eq("Shingeki no Kyojin")
    end
  end
end
