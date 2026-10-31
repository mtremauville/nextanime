require "rails_helper"

RSpec.describe SwipeDeckQuery do
  let(:action) { create(:genre, name: "Action") }
  let(:romance) { create(:genre, name: "Romance") }

  def anime(**attributes)
    defaults = { cover_image_url: "https://img.test/cover.jpg", format: :tv, start_date: Date.new(2021, 1, 1) }
    create(:anime, **defaults.merge(attributes))
  end

  describe "#call" do
    it "returns at most the requested number of anime" do
      create_list(:anime, 5, cover_image_url: "https://img.test/cover.jpg")

      expect(described_class.new(size: 3).call.size).to eq(3)
    end

    it "builds a deck of 24 anime by default" do
      create_list(:anime, 30, cover_image_url: "https://img.test/cover.jpg")

      expect(described_class.new.call.size).to eq(24)
    end

    it "ignores the anime without a cover" do
      with_cover = anime
      create(:anime, cover_image_url: nil)

      expect(described_class.new.call).to eq([ with_cover ])
    end

    it "puts the most popular anime first when nothing sets them apart" do
      low = anime(popularity: 10)
      top = anime(popularity: 100)
      middle = anime(popularity: 50)

      expect(described_class.new.call).to eq([ top, middle, low ])
    end

    it "puts the anime without popularity last" do
      unknown = anime(popularity: nil)
      known = anime(popularity: 1)

      expect(described_class.new.call).to eq([ known, unknown ])
    end

    it "mixes the genres before repeating one" do
      first = anime(popularity: 100, genres: [ action ])
      anime(popularity: 90, genres: [ action ])
      other_genre = anime(popularity: 10, genres: [ romance ])

      expect(described_class.new(size: 2).call).to contain_exactly(first, other_genre)
    end

    it "mixes the formats" do
      first = anime(popularity: 100, format: :tv)
      anime(popularity: 90, format: :tv)
      movie = anime(popularity: 10, format: :movie)

      expect(described_class.new(size: 2).call).to contain_exactly(first, movie)
    end

    it "mixes the decades" do
      first = anime(popularity: 100, start_date: Date.new(2021, 4, 1))
      anime(popularity: 90, start_date: Date.new(2023, 4, 1))
      older = anime(popularity: 10, start_date: Date.new(1995, 4, 1))

      expect(described_class.new(size: 2).call).to contain_exactly(first, older)
    end

    it "copes with an anime that has no start date nor format" do
      bare = anime(start_date: nil, format: nil)

      expect(described_class.new.call).to eq([ bare ])
    end

    it "returns the whole catalog when it is smaller than the deck" do
      animes = Array.new(3) { anime }

      expect(described_class.new.call).to match_array(animes)
    end

    it "returns an empty deck for an empty catalog" do
      expect(described_class.new.call).to eq([])
    end
  end

  describe "excluding anime already swiped" do
    let!(:animes) { create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg") }

    it "keeps every anime when nothing is excluded" do
      expect(described_class.new.call).to include(*animes)
    end

    it "leaves the excluded anime out of the deck" do
      deck = described_class.new(excluding: [ animes.first.id ]).call

      expect(deck).not_to include(animes.first)
      expect(deck).to include(*animes.drop(1))
    end

    it "leaves nothing of the catalog when everything is excluded" do
      deck = described_class.new(excluding: animes.map(&:id)).call

      expect(deck.map(&:id) & animes.map(&:id)).to be_empty
    end
  end
end
