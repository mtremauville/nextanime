require "rails_helper"

RSpec.describe MatchScorer do
  def anime_with(genres: [], tags: {})
    anime = create(:anime, genres: genres.map { |name| create(:genre, name: name) })
    tags.each { |name, rank| create(:anime_tag, anime: anime, tag: create(:tag, name: name), rank: rank) }
    anime.reload
  end

  def profile_with(genres: {}, tags: {})
    TasteProfile.new(genre_weights: genres, tag_weights: tags)
  end

  describe "#call" do
    it "gives 1 to an anime made only of what the profile loves" do
      profile = profile_with(genres: { "Action" => 1.0 }, tags: { "Time Loop" => 1.0 })
      anime = anime_with(genres: [ "Action" ], tags: { "Time Loop" => 100 })

      expect(described_class.new(profile).call(anime)).to eq(1.0)
    end

    it "gives 0 to an anime made only of what the profile rejects" do
      profile = profile_with(genres: { "Action" => -1.0 }, tags: { "Time Loop" => -1.0 })
      anime = anime_with(genres: [ "Action" ], tags: { "Time Loop" => 100 })

      expect(described_class.new(profile).call(anime)).to eq(0.0)
    end

    it "stays neutral for an anime the profile knows nothing about" do
      profile = profile_with(genres: { "Action" => 1.0 }, tags: { "Time Loop" => 1.0 })
      anime = anime_with(genres: [ "Romance" ], tags: { "School" => 80 })

      expect(described_class.new(profile).call(anime)).to eq(0.5)
    end

    it "stays neutral for an anime without genres and tags" do
      expect(described_class.new(profile_with).call(anime_with)).to eq(0.5)
    end

    it "averages the genres, an unknown genre counting for nothing" do
      profile = profile_with(genres: { "Action" => 1.0 })
      anime = anime_with(genres: [ "Action", "Drama" ])

      expect(described_class.new(profile).call(anime)).to be_within(0.0001).of(0.75)
    end

    it "weights the tags by their rank" do
      profile = profile_with(tags: { "Time Loop" => 1.0, "School" => -1.0 })
      anime = anime_with(tags: { "Time Loop" => 100, "School" => 25 })

      expect(described_class.new(profile).call(anime)).to be_within(0.0001).of(0.8)
    end

    it "gives the tags more say than the genres" do
      profile = profile_with(genres: { "Action" => 1.0 }, tags: { "School" => -1.0 })
      anime = anime_with(genres: [ "Action" ], tags: { "School" => 100 })

      expect(described_class.new(profile).call(anime)).to be_within(0.0001).of(0.4)
    end

    it "ranks an anime close to the taste above one far from it" do
      profile = profile_with(genres: { "Action" => 0.8, "Romance" => -0.8 })
      loved = anime_with(genres: [ "Action" ])
      rejected = anime_with(genres: [ "Romance" ])
      scorer = described_class.new(profile)

      expect(scorer.call(loved)).to be > scorer.call(rejected)
    end
  end

  describe "#percentage" do
    it "turns the score into a whole percentage" do
      profile = profile_with(tags: { "Time Loop" => 1.0, "School" => -1.0 })
      anime = anime_with(tags: { "Time Loop" => 100, "School" => 25 })

      expect(described_class.new(profile).percentage(anime)).to eq(80)
    end
  end

  describe "#scores" do
    let(:profile) do
      profile_with(
        genres: { "Action" => 1.0, "Drama" => -0.5, "Comedy" => 0.3 },
        tags: { "Time Loop" => 0.8, "School" => -0.6 }
      )
    end
    let(:scorer) { described_class.new(profile) }
    let!(:animes) do
      [
        anime_with(genres: [ "Action", "Drama" ], tags: { "Time Loop" => 100, "School" => 40 }),
        anime_with(genres: [ "Comedy" ]),
        anime_with(tags: { "Mecha" => 10 }),
        anime_with
      ]
    end

    it "gives each anime the score that #call gives it" do
      expected = animes.to_h { |anime| [ anime.id, scorer.call(anime) ] }

      expect(scorer.scores(animes.map(&:id))).to eq(expected)
    end

    it "gives 0.5 to an anime without genres and tags" do
      expect(scorer.scores([ animes.last.id ])).to eq(animes.last.id => 0.5)
    end

    it "only scores the anime it is given" do
      expect(scorer.scores([ animes.first.id ]).keys).to eq([ animes.first.id ])
    end

    it "scores nothing when it is given nothing" do
      expect(scorer.scores([])).to eq({})
    end

    it "reads the genres and the tags in two queries, whatever the number of anime" do
      queries = []
      counter = ->(*, payload) { queries << payload[:sql] unless payload[:name] == "SCHEMA" }

      ActiveSupport::Notifications.subscribed(counter, "sql.active_record") do
        scorer.scores(animes.map(&:id))
      end

      expect(queries.size).to eq(2)
    end
  end
end
