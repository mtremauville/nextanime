require "rails_helper"

RSpec.describe TasteProfileCalculator do
  subject(:weights) { described_class.new(profile).call }

  let(:profile) { create(:taste_profile) }

  def genre_named(name)
    Genre.find_by(name: name) || create(:genre, name: name)
  end

  def tag_named(name)
    Tag.find_by(name: name) || create(:tag, name: name)
  end

  def anime_with_genres(*names)
    create(:anime).tap do |anime|
      names.each { |name| create(:anime_genre, anime: anime, genre: genre_named(name)) }
    end
  end

  def anime_with_tag(name, rank:)
    create(:anime).tap { |anime| create(:anime_tag, anime: anime, tag: tag_named(name), rank: rank) }
  end

  def swipe(anime, liked:, on: profile)
    create(:swipe, taste_profile: on, anime: anime, liked: liked)
  end

  context "without any swipe" do
    it "has no weight at all" do
      expect(weights).to eq(genre_weights: {}, tag_weights: {})
    end
  end

  describe "genre weights" do
    it "gives a positive weight to a liked genre, smoothed for a single swipe" do
      swipe(anime_with_genres("Action"), liked: true)

      expect(weights[:genre_weights]).to eq("Action" => 0.3333)
    end

    it "gives a negative weight to a passed genre" do
      swipe(anime_with_genres("Action"), liked: false)

      expect(weights[:genre_weights]).to eq("Action" => -0.3333)
    end

    it "grows with the likes" do
      5.times { swipe(anime_with_genres("Action"), liked: true) }

      expect(weights[:genre_weights]).to eq("Action" => 0.7143)
    end

    it "reaches the strong affinity of a long series of likes" do
      24.times { swipe(anime_with_genres("Action"), liked: true) }

      expect(weights[:genre_weights]).to eq("Action" => 0.9231)
    end

    it "balances the likes against the passes" do
      3.times { swipe(anime_with_genres("Action"), liked: true) }
      swipe(anime_with_genres("Action"), liked: false)

      expect(weights[:genre_weights]).to eq("Action" => 0.3333)
    end

    it "counts every genre of the anime" do
      swipe(anime_with_genres("Action", "Drame"), liked: true)

      expect(weights[:genre_weights]).to eq("Action" => 0.3333, "Drame" => 0.3333)
    end

    it "weighs each genre on its own" do
      swipe(anime_with_genres("Action"), liked: true)
      swipe(anime_with_genres("Drame"), liked: false)

      expect(weights[:genre_weights]).to eq("Action" => 0.3333, "Drame" => -0.3333)
    end

    it "ignores the genres that were never swiped" do
      genre_named("Horreur")
      swipe(anime_with_genres("Action"), liked: true)

      expect(weights[:genre_weights]).not_to have_key("Horreur")
    end

    it "ignores the swipes of other profiles" do
      swipe(anime_with_genres("Action"), liked: true, on: create(:taste_profile))

      expect(weights[:genre_weights]).to eq({})
    end
  end

  describe "tag weights" do
    it "weighs a swipe by the rank of the tag" do
      swipe(anime_with_tag("Manipulation", rank: 80), liked: true)

      expect(weights[:tag_weights]).to eq("Manipulation" => 0.2857)
    end

    it "barely counts a tag that hardly describes the anime" do
      swipe(anime_with_tag("Manipulation", rank: 10), liked: true)

      expect(weights[:tag_weights]).to eq("Manipulation" => 0.0476)
    end

    it "gives a negative weight to a passed tag" do
      swipe(anime_with_tag("Manipulation", rank: 50), liked: false)

      expect(weights[:tag_weights]).to eq("Manipulation" => -0.2)
    end

    it "adds up the ranks of the swipes sharing a tag" do
      swipe(anime_with_tag("Manipulation", rank: 100), liked: true)
      swipe(anime_with_tag("Manipulation", rank: 50), liked: true)

      expect(weights[:tag_weights]).to eq("Manipulation" => 0.4286)
    end

    it "leaves the genres alone" do
      swipe(anime_with_tag("Manipulation", rank: 80), liked: true)

      expect(weights[:genre_weights]).to eq({})
    end
  end
end
