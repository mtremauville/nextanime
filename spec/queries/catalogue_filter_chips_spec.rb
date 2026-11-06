require "rails_helper"

RSpec.describe CatalogueFilterChips do
  let(:thriller) { Genre.new(id: 4, name: "Thriller") }
  let(:drama) { Genre.new(id: 7, name: "Drame") }
  let(:genres) { [ thriller, drama ] }
  let(:mappa) { CatalogueStudios::Option.new(id: 3, name: "MAPPA", count: 38) }
  let(:bones) { CatalogueStudios::Option.new(id: 8, name: "Bones", count: 41) }
  let(:studios) { [ mappa, bones ] }

  def chips_for(params)
    described_class.new(filters: CatalogueFilters.from_params(params), genres: genres, studios: studios).call
  end

  def labels_for(params) = chips_for(params).map(&:label)

  it "gives nothing when no filter is active" do
    expect(chips_for({})).to eq([])
  end

  it "gives one chip per selected genre, named after the genre" do
    expect(labels_for(genre_ids: %w[4 7])).to eq(%w[Thriller Drame])
  end

  it "gives no chip to a genre that does not exist" do
    expect(labels_for(genre_ids: %w[4 99])).to eq(%w[Thriller])
  end

  it "names a format" do
    expect(labels_for(formats: %w[movie])).to eq(%w[Film])
  end

  it "names a status" do
    expect(labels_for(statuses: %w[finished])).to eq(%w[Terminé])
  end

  it "names the season" do
    expect(labels_for(season: "winter")).to eq(%w[Hiver])
  end

  it "names the two years as a range" do
    expect(labels_for(year_from: "2000", year_to: "2010")).to eq([ "2000–2010" ])
  end

  it "names a first year alone" do
    expect(labels_for(year_from: "2000")).to eq([ "Depuis 2000" ])
  end

  it "names a last year alone" do
    expect(labels_for(year_to: "2010")).to eq([ "Jusqu'en 2010" ])
  end

  it "lists the genres, the formats, the season, the years and the statuses, in that order" do
    params = { genre_ids: %w[4], formats: %w[movie], season: "winter", year_from: "2000", year_to: "2010", statuses: %w[finished] }

    expect(labels_for(params)).to eq([ "Thriller", "Film", "Hiver", "2000–2010", "Terminé" ])
  end

  it "gives, with each chip, the filters that remain once it is removed" do
    chip = chips_for(genre_ids: %w[4 7], formats: %w[movie]).first

    expect(chip.remaining.to_query_params).to eq(genre_ids: [ 7 ], formats: [ "movie" ])
  end

  it "removes both years with the chip of the years" do
    chip = chips_for(year_from: "2000", year_to: "2010", season: "winter").find { |each| each.label == "2000–2010" }

    expect(chip.remaining.to_query_params).to eq(season: "winter")
  end

  describe "studio chips" do
    it "gives one chip per selected studio, named after the studio" do
      expect(labels_for(studio_ids: %w[3 8])).to eq(%w[MAPPA Bones])
    end

    it "gives no chip to a studio that is not listed" do
      expect(labels_for(studio_ids: %w[3 99])).to eq(%w[MAPPA])
    end

    it "gives, with a studio chip, the filters that remain once it is removed" do
      expect(chips_for(studio_ids: %w[3 8]).first.remaining.studio_ids).to eq([ 8 ])
    end

    it "puts the studios after the genres and before the formats" do
      expect(labels_for(genre_ids: %w[4], studio_ids: %w[3], formats: %w[movie])).to eq(%w[Thriller MAPPA Film])
    end
  end
end
