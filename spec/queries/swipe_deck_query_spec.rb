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

    it "builds a deck of 20 anime by default" do
      create_list(:anime, 30, cover_image_url: "https://img.test/cover.jpg")

      expect(described_class.new.call.size).to eq(20)
    end

    it "ignores the anime without a cover" do
      with_cover = anime
      create(:anime, cover_image_url: nil)

      expect(described_class.new.call).to eq([ with_cover ])
    end

    it "draws only from the most popular anime" do
      stub_const("SwipeDeckQuery::CANDIDATES_LIMIT", 2)
      top = anime(popularity: 100)
      middle = anime(popularity: 50)
      anime(popularity: 10)
      anime(popularity: nil)

      expect(described_class.new.call).to contain_exactly(top, middle)
    end

    it "mixes the genres before repeating one" do
      anime(genres: [ action ])
      anime(genres: [ action ])
      other_genre = anime(genres: [ romance ])

      expect(described_class.new(size: 2).call).to include(other_genre)
    end

    it "mixes the formats" do
      anime(format: :tv)
      anime(format: :tv)
      movie = anime(format: :movie)

      expect(described_class.new(size: 2).call).to include(movie)
    end

    it "mixes the decades" do
      anime(start_date: Date.new(2021, 4, 1))
      anime(start_date: Date.new(2023, 4, 1))
      older = anime(start_date: Date.new(1995, 4, 1))

      expect(described_class.new(size: 2).call).to include(older)
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

  describe "randomness" do
    before { Array.new(10) { |index| anime(popularity: index + 1) } }

    it "draws the same deck from the same random source" do
      first_draw = described_class.new(random: Random.new(1)).call
      second_draw = described_class.new(random: Random.new(1)).call

      expect(first_draw).to eq(second_draw)
    end

    it "draws a different deck from another random source" do
      first_draw = described_class.new(random: Random.new(1)).call
      second_draw = described_class.new(random: Random.new(2)).call

      expect(first_draw).not_to eq(second_draw)
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
