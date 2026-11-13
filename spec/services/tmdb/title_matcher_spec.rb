require "rails_helper"

RSpec.describe Tmdb::TitleMatcher do
  subject(:matcher) { described_class.new }

  let(:anime) do
    build(:anime, title_english: "Frieren: Beyond Journey's End", title_romaji: "Sousou no Frieren",
                  title_native: "葬送のフリーレン", season_year: 2023)
  end

  def series(id: 209_867, name: "Frieren: Beyond Journey's End", original_name: "葬送のフリーレン",
             date: "2023-09-29", genre_ids: [ 16, 18 ])
    { "id" => id, "name" => name, "original_name" => original_name, "first_air_date" => date, "genre_ids" => genre_ids }
  end

  def film(id: 129, title: "Spirited Away", original_title: "千と千尋の神隠し", date: "2001-07-20", genre_ids: [ 16 ])
    { "id" => id, "title" => title, "original_title" => original_title, "release_date" => date, "genre_ids" => genre_ids }
  end

  def match_id(results, subject_anime = anime, media_type: :tv)
    matcher.match(subject_anime, results, media_type: media_type)&.fetch("id")
  end

  describe "#match" do
    it "finds the series with the same title and year" do
      expect(match_id([ series ])).to eq(209_867)
    end

    it "finds the series through the original title" do
      candidate = series(name: "Frieren Beyond", original_name: "葬送のフリーレン")

      expect(match_id([ candidate ])).to eq(209_867)
    end

    it "finds the series through the romaji title" do
      candidate = series(name: "Sousou no Frieren", original_name: "Something else")

      expect(match_id([ candidate ])).to eq(209_867)
    end

    it "ignores the case and the punctuation of the titles" do
      candidate = series(name: "FRIEREN - Beyond Journeys End!", original_name: "Other")

      expect(match_id([ candidate ])).to eq(209_867)
    end

    it "ignores a result that is not an animation" do
      expect(match_id([ series(genre_ids: [ 18, 10_765 ]) ])).to be_nil
    end

    it "ignores a result whose title is different" do
      candidate = series(name: "Another Show", original_name: "Another Original")

      expect(match_id([ candidate ])).to be_nil
    end

    it "accepts a year that is one year apart" do
      expect(match_id([ series(date: "2024-01-05") ])).to eq(209_867)
    end

    it "ignores a result that is more than one year apart" do
      expect(match_id([ series(date: "2020-09-29") ])).to be_nil
    end

    it "ignores a result without date" do
      expect(match_id([ series(date: "") ])).to be_nil
    end

    it "uses the start date when the season year is unknown" do
      dated_anime = build(:anime, title_native: "葬送のフリーレン", season_year: nil, start_date: Date.new(2023, 9, 29))

      expect(match_id([ series ], dated_anime)).to eq(209_867)
    end

    it "does not match an anime without any known year" do
      yearless_anime = build(:anime, title_native: "葬送のフリーレン", season_year: nil, start_date: nil)

      expect(match_id([ series ], yearless_anime)).to be_nil
    end

    it "keeps the candidate whose year is the closest" do
      results = [ series(id: 1, date: "2022-10-01"), series(id: 2, date: "2023-09-29") ]

      expect(match_id(results)).to eq(2)
    end

    it "keeps the most relevant candidate when the years are equal" do
      results = [ series(id: 1), series(id: 2) ]

      expect(match_id(results)).to eq(1)
    end

    it "reads the title and the release date of a film" do
      movie_anime = build(:anime, title_english: "Spirited Away", format: :movie, season_year: 2001)

      expect(match_id([ film ], movie_anime, media_type: :movie)).to eq(129)
    end

    it "returns nil when there is no result" do
      expect(matcher.match(anime, [], media_type: :tv)).to be_nil
    end
  end
  describe "#match with titles that differ in their form" do
    it "ignores a year or a qualifier in the title of the anime" do
      hunter = build(:anime, title_english: "Hunter x Hunter (2011)", title_romaji: "HUNTER×HUNTER (2011)", season_year: 2011)
      candidate = series(id: 46_298, name: "Hunter x Hunter", original_name: "HUNTER×HUNTER", date: "2011-10-02")

      expect(match_id([ candidate ], hunter)).to eq(46_298)
    end

    it "ignores the accents of the titles" do
      naruto = build(:anime, title_english: "Naruto: Shippuden", season_year: 2007)
      candidate = series(id: 31_910, name: "Naruto Shippūden", original_name: "ナルト 疾風伝", date: "2007-02-15")

      expect(match_id([ candidate ], naruto)).to eq(31_910)
    end

    it "ignores the mention of the film in the title" do
      voice = build(:anime, title_english: "A Silent Voice", title_native: "聲の形", format: :movie, season_year: 2016)
      candidate = film(id: 378_064, title: "A Silent Voice: The Movie", original_title: "映画 聲の形", date: "2016-09-17")

      expect(match_id([ candidate ], voice, media_type: :movie)).to eq(378_064)
    end
  end
end
