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
  describe "#match for the later seasons of a series" do
    def japanese_series(**attributes)
      series(**attributes).merge("origin_country" => [ "JP" ])
    end

    let(:titan_season2) do
      build(:anime, title_english: "Attack on Titan Season 2", title_romaji: "Shingeki no Kyojin Season 2",
                    title_native: "進撃の巨人 Season２", season_year: 2017)
    end
    let(:titan) { japanese_series(id: 1429, name: "Attack on Titan", original_name: "進撃の巨人", date: "2013-04-07") }

    it "matches a later season with the series it belongs to" do
      expect(match_id([ titan ], titan_season2)).to eq(1429)
    end

    it "matches an arc through the start of its title" do
      arc = build(:anime, title_english: "Demon Slayer: Kimetsu no Yaiba Entertainment District Arc", season_year: 2022)
      demon_slayer = japanese_series(id: 85_937, name: "Demon Slayer: Kimetsu no Yaiba", original_name: "鬼滅の刃", date: "2019-04-06")

      expect(match_id([ demon_slayer ], arc)).to eq(85_937)
    end

    it "matches through the original title when the english one differs" do
      other_english = build(:anime, title_english: "Totally Different Season 2", title_native: "進撃の巨人 Season２", season_year: 2017)

      expect(match_id([ titan ], other_english)).to eq(1429)
    end

    it "prefers the series that has the very same title" do
      attack = build(:anime, title_english: "Attack on Titan", season_year: 2013)
      shorter = japanese_series(id: 5, name: "Attack", original_name: "Attack", date: "2013-01-01")
      same_title = japanese_series(id: 6, name: "Attack on Titan", original_name: "進撃の巨人", date: "2013-04-07")

      expect(match_id([ shorter, same_title ], attack)).to eq(6)
    end

    it "keeps the series whose year is the closest" do
      older = japanese_series(id: 1, date: "2008-04-07")
      closer = japanese_series(id: 2, date: "2013-04-07")
      later_season = build(:anime, title_english: "Frieren: Beyond Journey's End Season 2", season_year: 2017)

      expect(match_id([ older, closer ], later_season)).to eq(2)
    end

    it "accepts a series that started ten years before" do
      expect(match_id([ japanese_series(id: 7, name: "Attack on Titan", original_name: "進撃の巨人", date: "2007-04-07") ], titan_season2)).to eq(7)
    end

    it "ignores a series that started more than ten years before" do
      expect(match_id([ japanese_series(id: 7, name: "Attack on Titan", original_name: "進撃の巨人", date: "2005-04-07") ], titan_season2)).to be_nil
    end

    it "ignores a series that started after the anime" do
      expect(match_id([ japanese_series(id: 7, name: "Attack on Titan", original_name: "進撃の巨人", date: "2019-04-07") ], titan_season2)).to be_nil
    end

    it "ignores a series that is not Japanese" do
      expect(match_id([ titan.merge("origin_country" => [ "US" ]) ], titan_season2)).to be_nil
    end

    it "ignores a series that is not an animation" do
      expect(match_id([ titan.merge("genre_ids" => [ 18 ]) ], titan_season2)).to be_nil
    end

    it "ignores a title that is too short to be told apart" do
      ao_ashi = build(:anime, title_english: "Ao Ashi", season_year: 2022)
      ao = japanese_series(id: 8, name: "Ao", original_name: "Ao", date: "2020-01-01")

      expect(match_id([ ao ], ao_ashi)).to be_nil
    end

    it "ignores a series with the very same title that is years apart" do
      same_title = build(:anime, title_english: "Attack on Titan", season_year: 2017)

      expect(match_id([ titan ], same_title)).to be_nil
    end

    it "does not apply to a film" do
      returns = build(:anime, title_english: "Spirited Away Returns", format: :movie, season_year: 2003)
      spirited_away = film(id: 129, title: "Spirited Away", original_title: "千と千尋の神隠し", date: "2001-07-20").merge("origin_country" => [ "JP" ])

      expect(match_id([ spirited_away ], returns, media_type: :movie)).to be_nil
    end
  end
end
