require "rails_helper"

RSpec.describe CatalogueQuery, "with filters" do
  def filters(**given)
    CatalogueFilters.new(**{ genre_ids: [], studio_ids: [], formats: [], statuses: [], season: nil, year_from: nil, year_to: nil }.merge(given))
  end

  def titles_for(search: nil, **given)
    described_class.new(filters: filters(**given), search: search).call.animes.map(&:title_romaji)
  end

  describe "without any filter" do
    it "lists every anime" do
      create(:anime, title_romaji: "Alpha")
      create(:anime, title_romaji: "Beta")

      expect(titles_for).to match_array(%w[Alpha Beta])
    end

    it "does not need filters at all" do
      create(:anime, title_romaji: "Alpha")

      expect(described_class.new.call.animes.map(&:title_romaji)).to eq(%w[Alpha])
    end
  end

  describe "genres" do
    let(:action) { create(:genre, name: "Action") }
    let(:comedy) { create(:genre, name: "Comedy") }

    before do
      create(:anime, title_romaji: "Both", genres: [ action, comedy ])
      create(:anime, title_romaji: "Only action", genres: [ action ])
      create(:anime, title_romaji: "No genre")
    end

    it "keeps the anime of one genre" do
      expect(titles_for(genre_ids: [ action.id ])).to match_array([ "Both", "Only action" ])
    end

    it "keeps only the anime that have every selected genre, once each" do
      expect(titles_for(genre_ids: [ action.id, comedy.id ])).to eq([ "Both" ])
    end

    it "finds nothing for a genre that does not exist" do
      expect(titles_for(genre_ids: [ 0 ])).to eq([])
    end
  end

  describe "formats" do
    before do
      create(:anime, title_romaji: "Series", format: :tv)
      create(:anime, title_romaji: "Film", format: :movie)
      create(:anime, title_romaji: "Original", format: :ova)
      create(:anime, title_romaji: "Unknown", format: nil)
    end

    it "keeps one format" do
      expect(titles_for(formats: %w[movie])).to eq(%w[Film])
    end

    it "keeps any of several formats" do
      expect(titles_for(formats: %w[tv ova])).to match_array(%w[Series Original])
    end
  end

  describe "statuses" do
    before do
      create(:anime, title_romaji: "Done", airing_status: :finished)
      create(:anime, title_romaji: "Ongoing", airing_status: :releasing)
      create(:anime, title_romaji: "Soon", airing_status: :not_yet_released)
    end

    it "keeps one status" do
      expect(titles_for(statuses: %w[releasing])).to eq(%w[Ongoing])
    end

    it "keeps any of several statuses" do
      expect(titles_for(statuses: %w[releasing not_yet_released])).to match_array(%w[Ongoing Soon])
    end
  end

  describe "season" do
    before do
      create(:anime, title_romaji: "Autumn one", season: :fall)
      create(:anime, title_romaji: "Spring one", season: :spring)
      create(:anime, title_romaji: "No season", season: nil)
    end

    it "keeps the anime of the season, whatever the year" do
      expect(titles_for(season: "fall")).to eq([ "Autumn one" ])
    end
  end

  describe "years" do
    before do
      create(:anime, title_romaji: "Old", season_year: 1995)
      create(:anime, title_romaji: "Middle", season_year: 2005)
      create(:anime, title_romaji: "Recent", season_year: 2020)
      create(:anime, title_romaji: "Undated", season_year: nil)
    end

    it "keeps the years from the first to the last, both included" do
      expect(titles_for(year_from: 1995, year_to: 2005)).to match_array(%w[Old Middle])
    end

    it "keeps everything from a first year on" do
      expect(titles_for(year_from: 2005)).to match_array(%w[Middle Recent])
    end

    it "keeps everything up to a last year" do
      expect(titles_for(year_to: 2005)).to match_array(%w[Old Middle])
    end

    it "leaves out the anime without a year as soon as a year is asked" do
      expect(titles_for(year_from: 1900)).not_to include("Undated")
    end
  end

  describe "several filters at once" do
    before do
      create(:anime, title_romaji: "Series of autumn", format: :tv, season: :fall, season_year: 2020)
      create(:anime, title_romaji: "Film of autumn", format: :movie, season: :fall, season_year: 2020)
      create(:anime, title_romaji: "Series of spring", format: :tv, season: :spring, season_year: 2020)
    end

    it "keeps only the anime that fit all of them" do
      expect(titles_for(formats: %w[tv], season: "fall")).to eq([ "Series of autumn" ])
    end

    it "works with the search" do
      expect(titles_for(search: "film", season: "fall")).to eq([ "Film of autumn" ])
    end
  end

  describe "the page" do
    before do
      create_list(:anime, 3, format: :tv)
      create_list(:anime, 2, format: :movie)
    end

    it "counts and splits only the anime that are kept" do
      page = described_class.new(filters: filters(formats: %w[tv]), per_page: 2).call

      expect([ page.total_count, page.total_pages, page.animes.size ]).to eq([ 3, 2, 2 ])
    end
  end

  describe "studios" do
    let(:mappa) { create(:studio, name: "MAPPA") }
    let(:bones) { create(:studio, name: "Bones") }

    before do
      by_both = create(:anime, title_romaji: "By both")
      create(:anime_studio, anime: by_both, studio: mappa, main: true)
      create(:anime_studio, anime: by_both, studio: bones)
      create(:anime, title_romaji: "Only MAPPA", studios: [ mappa ])
      create(:anime, title_romaji: "Only Bones", studios: [ bones ])
      create(:anime, title_romaji: "No studio")
    end

    it "keeps the anime of one studio" do
      expect(titles_for(studio_ids: [ mappa.id ])).to match_array([ "By both", "Only MAPPA" ])
    end

    it "keeps the anime of any of several studios, once each" do
      expect(titles_for(studio_ids: [ mappa.id, bones.id ])).to match_array([ "By both", "Only MAPPA", "Only Bones" ])
    end

    it "counts an anime once in the page when several of its studios are selected" do
      page = described_class.new(filters: filters(studio_ids: [ mappa.id, bones.id ])).call

      expect(page.total_count).to eq(3)
    end

    it "keeps the anime whose selected studio is not the main one" do
      expect(titles_for(studio_ids: [ bones.id ])).to match_array([ "By both", "Only Bones" ])
    end

    it "finds nothing for a studio that does not exist" do
      expect(titles_for(studio_ids: [ 0 ])).to eq([])
    end

    it "works with the search" do
      expect(titles_for(search: "only", studio_ids: [ mappa.id ])).to eq([ "Only MAPPA" ])
    end
  end
end
