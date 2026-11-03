require "rails_helper"

RSpec.describe AnimeSummary do
  def anime_with(studio: nil, **attributes)
    anime = create(:anime, format: nil, start_date: nil, episodes: nil, **attributes)
    create(:anime_studio, anime: anime, studio: create(:studio, name: studio), main: true) if studio
    anime.reload
  end

  describe "#badge" do
    it "joins the format and the year of the first airing" do
      anime = anime_with(format: :tv, start_date: Date.new(2019, 4, 6))

      expect(described_class.new(anime).badge).to eq("Série · 2019")
    end

    it "keeps the format alone when the date is unknown" do
      expect(described_class.new(anime_with(format: :movie)).badge).to eq("Film")
    end

    it "is empty when the format and the date are unknown" do
      expect(described_class.new(anime_with).badge).to be_nil
    end
  end

  describe "#meta" do
    it "joins the main studio and the number of episodes" do
      anime = anime_with(studio: "MAPPA", episodes: 12)

      expect(described_class.new(anime).meta).to eq("MAPPA · 12 épisodes")
    end

    it "uses the singular for a single episode" do
      expect(described_class.new(anime_with(episodes: 1)).meta).to eq("1 épisode")
    end

    it "is empty when the studio and the episodes are unknown" do
      expect(described_class.new(anime_with).meta).to be_nil
    end
  end

  describe "#line" do
    it "joins the format, the year and the main studio" do
      anime = anime_with(format: :tv, start_date: Date.new(2019, 4, 6), studio: "MAPPA")

      expect(described_class.new(anime).line).to eq("Série · 2019 · MAPPA")
    end

    it "leaves out what is unknown" do
      anime = anime_with(format: :tv, start_date: Date.new(2019, 4, 6))

      expect(described_class.new(anime).line).to eq("Série · 2019")
    end

    it "is empty when nothing is known" do
      expect(described_class.new(anime_with).line).to be_nil
    end
  end

  describe "#genre_labels" do
    it "gives the names of the first three genres" do
      genres = %w[Action Drama Comedy Horror].map { |name| create(:genre, name: name) }
      anime = anime_with(genres: genres)

      expect(described_class.new(anime).genre_labels).to eq(%w[Action Drama Comedy])
    end
  end
end
