require "rails_helper"

RSpec.describe AnimeDetails do
  BLANK = {
    format: nil, start_date: nil, episodes: nil, airing_status: nil, season: nil,
    season_year: nil, average_score: nil, description: nil
  }.freeze

  def anime_with(studio: nil, genres: [], tags: {}, **attributes)
    anime = create(:anime, **BLANK, **attributes, genres: genres.map { |name| create(:genre, name: name) })
    create(:anime_studio, anime: anime, studio: create(:studio, name: studio), main: true) if studio
    tags.each { |name, rank| create(:anime_tag, anime: anime, tag: create(:tag, name: name), rank: rank) }
    anime.reload
  end

  def details_of(anime) = described_class.new(anime)

  describe "#eyebrow" do
    it "joins the format, the year and the status" do
      anime = anime_with(format: :tv, start_date: Date.new(2022, 10, 12), airing_status: :finished)

      expect(details_of(anime).eyebrow).to eq("Série · 2022 · Terminé")
    end

    it "leaves out the status when it is unknown" do
      anime = anime_with(format: :tv, start_date: Date.new(2022, 10, 12))

      expect(details_of(anime).eyebrow).to eq("Série · 2022")
    end

    it "is empty when nothing is known" do
      expect(details_of(anime_with).eyebrow).to be_nil
    end
  end

  describe "#meta" do
    it "joins the main studio and the number of episodes" do
      expect(details_of(anime_with(studio: "MAPPA", episodes: 12)).meta).to eq("MAPPA · 12 épisodes")
    end
  end

  describe "#genre_labels" do
    it "lists every genre, not only the first ones" do
      anime = anime_with(genres: %w[Action Drama Horror Thriller])

      expect(details_of(anime).genre_labels).to match_array(%w[Action Drama Horror Thriller])
    end
  end

  describe "#season_label" do
    it "joins the season and its year" do
      expect(details_of(anime_with(season: :fall, season_year: 2022)).season_label).to eq("Automne 2022")
    end

    it "keeps the year alone when the season is unknown" do
      expect(details_of(anime_with(season_year: 2022)).season_label).to eq("2022")
    end

    it "is empty when neither is known" do
      expect(details_of(anime_with).season_label).to be_nil
    end
  end

  describe "#status_label" do
    it "names the airing status" do
      expect(details_of(anime_with(airing_status: :releasing)).status_label).to eq("En cours de diffusion")
    end

    it "is empty when the status is unknown" do
      expect(details_of(anime_with).status_label).to be_nil
    end
  end

  describe "#score_label" do
    it "shows the average score out of 100" do
      expect(details_of(anime_with(average_score: 82)).score_label).to eq("82 / 100")
    end

    it "is empty when there is no score" do
      expect(details_of(anime_with).score_label).to be_nil
    end
  end

  describe "#tags" do
    it "ranks the tags, the most relevant first, with their rank" do
      anime = anime_with(tags: { "Démons" => 92, "Humour noir" => 55, "Surnaturel" => 80 })

      tags = details_of(anime).tags

      expect(tags.map(&:name)).to eq([ "Démons", "Surnaturel", "Humour noir" ])
      expect(tags.map(&:rank)).to eq([ 92, 80, 55 ])
    end

    it "keeps the eight best tags" do
      anime = anime_with(tags: (1..10).to_h { |index| [ "Tag #{index}", index * 10 ] })

      expect(details_of(anime).tags.size).to eq(8)
      expect(details_of(anime).tags.first.name).to eq("Tag 10")
    end

    it "is empty without tags" do
      expect(details_of(anime_with).tags).to eq([])
    end
  end

  describe "#synopsis" do
    it "gives the description" do
      expect(details_of(anime_with(description: "Denji fuses with Pochita.")).synopsis).to eq("Denji fuses with Pochita.")
    end

    it "is empty when the description is blank" do
      expect(details_of(anime_with(description: "  ")).synopsis).to be_nil
    end
  end

  describe "#information" do
    it "lists what is known about the anime as label and value pairs" do
      anime = anime_with(format: :tv, episodes: 12, studio: "MAPPA", season: :fall, season_year: 2022,
                         airing_status: :finished, average_score: 82)

      expect(details_of(anime).information).to eq(
        [
          [ "Format", "Série" ], [ "Épisodes", "12" ], [ "Studio", "MAPPA" ],
          [ "Saison", "Automne 2022" ], [ "Statut", "Terminé" ], [ "Note moyenne", "82 / 100" ]
        ]
      )
    end

    it "leaves out what is unknown" do
      expect(details_of(anime_with(format: :movie)).information).to eq([ [ "Format", "Film" ] ])
    end

    it "leaves out the format when it is unknown" do
      details = described_class.new(build(:anime, format: nil))

      expect(details.information.map(&:first)).not_to include(I18n.t("animes.information.format"))
    end
  end
end
