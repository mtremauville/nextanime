require "rails_helper"

RSpec.describe Tmdb::AnimeLinker do
  include ActiveSupport::Testing::TimeHelpers

  subject(:linker) { described_class.new(client: client) }

  let(:client) { instance_double(Tmdb::Client, search: series_results) }
  let(:series_results) { JSON.parse(file_fixture("tmdb/search_tv.json").read).fetch("results") }
  let(:movie_results) { JSON.parse(file_fixture("tmdb/search_movie.json").read).fetch("results") }
  let(:anime) do
    create(:anime, title_english: "Frieren: Beyond Journey's End", title_romaji: "Sousou no Frieren", season_year: 2023)
  end

  describe "#link" do
    it "searches a series with its english title" do
      linker.link(anime)

      expect(client).to have_received(:search).with(media_type: :tv, query: "Frieren: Beyond Journey's End")
    end

    it "searches a film as a movie" do
      film = create(:anime, title_english: "Spirited Away", format: :movie, season_year: 2001)
      allow(client).to receive(:search).and_return(movie_results)

      match = linker.link(film)

      expect(client).to have_received(:search).with(media_type: :movie, query: "Spirited Away")
      expect(match).to have_attributes(tmdb_id: 129, media_type: "movie")
    end

    it "tries the romaji title when the english one finds nothing" do
      allow(client).to receive(:search).with(media_type: :tv, query: "Frieren: Beyond Journey's End").and_return([])
      allow(client).to receive(:search).with(media_type: :tv, query: "Sousou no Frieren").and_return(series_results)

      expect(linker.link(anime).tmdb_id).to eq(209_867)
    end

    it "searches only once when both titles are the same" do
      same_titles = create(:anime, title_english: "Frieren", title_romaji: "Frieren", season_year: 2023)
      allow(client).to receive(:search).and_return([])

      linker.link(same_titles)

      expect(client).to have_received(:search).once
    end

    it "does not search with a title that is missing" do
      romaji_only = create(:anime, title_english: nil, title_romaji: "Sousou no Frieren", season_year: 2023)
      allow(client).to receive(:search).and_return([])

      linker.link(romaji_only)

      expect(client).to have_received(:search).once.with(media_type: :tv, query: "Sousou no Frieren")
    end

    it "remembers the match" do
      freeze_time do
        match = linker.link(anime)

        expect(match).to be_persisted
        expect(match).to have_attributes(anime: anime, tmdb_id: 209_867, media_type: "tv", checked_at: Time.current)
      end
    end

    it "remembers that no TMDB title was found" do
      allow(client).to receive(:search).and_return([])

      match = linker.link(anime)

      expect(match).to be_persisted
      expect(match).not_to be_matched
      expect(match.media_type).to be_nil
    end

    context "when the anime already has a match" do
      before { create(:tmdb_match, anime: anime, tmdb_id: 42, media_type: :tv) }

      it "keeps it without searching again" do
        expect(linker.link(anime).tmdb_id).to eq(42)
        expect(client).not_to have_received(:search)
      end
    end

    context "when the anime could not be matched before" do
      before { create(:tmdb_match, :unmatched, anime: anime) }

      it "searches again and updates the same record" do
        expect { linker.link(anime) }.not_to change(TmdbMatch, :count)
        expect(anime.reload.tmdb_match.tmdb_id).to eq(209_867)
      end
    end
  end
  describe "#link with a qualifier in the title" do
    it "searches without the qualifier" do
      qualified = create(:anime, title_english: "JoJo's Bizarre Adventure (TV)", title_romaji: "JoJo no Kimyou na Bouken (TV)", season_year: 2012)
      allow(client).to receive(:search).and_return([])

      linker.link(qualified)

      expect(client).to have_received(:search).with(media_type: :tv, query: "JoJo's Bizarre Adventure")
    end

    it "does not search twice for titles that only differ by their qualifier" do
      doubled = create(:anime, title_english: "Frieren (TV)", title_romaji: "Frieren", season_year: 2023)
      allow(client).to receive(:search).and_return([])

      linker.link(doubled)

      expect(client).to have_received(:search).once
    end
  end
  describe "#link when the title ends with a season marker" do
    let(:attack_on_titan) do
      {
        "id" => 1429, "name" => "Attack on Titan", "original_name" => "進撃の巨人",
        "first_air_date" => "2013-04-07", "genre_ids" => [ 16 ], "origin_country" => [ "JP" ]
      }
    end
    let(:third_season) do
      create(:anime, title_english: "Attack on Titan Season 3", title_romaji: "Shingeki no Kyojin Season 3", season_year: 2018)
    end

    before do
      allow(client).to receive(:search).and_return([])
      allow(client).to receive(:search).with(media_type: :tv, query: "Attack on Titan").and_return([ attack_on_titan ])
    end

    it "finds the series when only the title without the season is known by TMDB" do
      expect(linker.link(third_season).tmdb_id).to eq(1429)
    end

    it "searches the full titles before the title of the series" do
      linker.link(third_season)

      expect(client).to have_received(:search).with(media_type: :tv, query: "Attack on Titan Season 3").ordered
      expect(client).to have_received(:search).with(media_type: :tv, query: "Shingeki no Kyojin Season 3").ordered
      expect(client).to have_received(:search).with(media_type: :tv, query: "Attack on Titan").ordered
    end

    it "searches the title of the series only once when both titles lead to the same one" do
      haikyu = create(:anime, title_english: "Haikyu!! 2nd Season", title_romaji: "Haikyu!! 2", season_year: 2015)

      linker.link(haikyu)

      expect(client).to have_received(:search).with(media_type: :tv, query: "Haikyu!!").once
    end
  end
end
