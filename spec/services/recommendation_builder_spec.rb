require "rails_helper"

RSpec.describe RecommendationBuilder do
  let(:profile) { TasteProfile.create!(session_token: "visitor", genre_weights: { "Action" => 1.0, "Romance" => -1.0 }) }
  let(:action) { create(:genre, name: "Action") }
  let(:romance) { create(:genre, name: "Romance") }

  def anime_of(*genres)
    create(:anime, genres: genres)
  end

  def recommended_anime_ids
    profile.recommendations.pluck(:anime_id)
  end

  it "scores every anime the profile has not swiped yet" do
    loved = anime_of(action)
    rejected = anime_of(romance)

    described_class.new(profile).call

    scores = profile.recommendations.to_h { |recommendation| [ recommendation.anime_id, recommendation.score.to_f ] }
    expect(scores).to eq(loved.id => 1.0, rejected.id => 0.0)
  end

  it "leaves out the anime the profile already swiped" do
    seen = anime_of(action)
    unseen = anime_of(action)
    profile.swipes.create!(anime: seen, liked: true)

    described_class.new(profile).call

    expect(recommended_anime_ids).to eq([ unseen.id ])
  end

  it "keeps only the best ones" do
    stub_const("RecommendationBuilder::LIMIT", 2)
    best = [ anime_of(action), anime_of(action) ]
    anime_of(romance)

    described_class.new(profile).call

    expect(recommended_anime_ids).to match_array(best.map(&:id))
  end

  it "drops the recommendation of an anime swiped since the last run" do
    swiped_later = anime_of(action)
    still_unseen = anime_of(action)
    described_class.new(profile).call

    profile.swipes.create!(anime: swiped_later, liked: false)
    described_class.new(profile).call

    expect(recommended_anime_ids).to eq([ still_unseen.id ])
  end

  it "updates the score of a recommendation and keeps its explanation" do
    anime_of(action)
    described_class.new(profile).call
    recommendation = profile.recommendations.first
    recommendation.update!(explanation: "Because you like action", explanation_digest: "abc")

    profile.update!(genre_weights: { "Action" => 0.5 })
    described_class.new(profile).call

    recommendation.reload
    expect(recommendation.score.to_f).to eq(0.75)
    expect(recommendation.explanation).to eq("Because you like action")
  end

  it "does not duplicate the recommendations when it runs twice" do
    anime_of(action)

    2.times { described_class.new(profile).call }

    expect(profile.recommendations.count).to eq(1)
  end

  it "returns the recommendations of the profile" do
    anime_of(action)

    expect(described_class.new(profile).call).to match_array(profile.recommendations)
  end

  it "empties the recommendations when nothing is left to recommend" do
    last_one = anime_of(action)
    described_class.new(profile).call

    profile.swipes.create!(anime: last_one, liked: true)
    described_class.new(profile).call

    expect(profile.recommendations).to be_empty
  end

  describe "#stale?" do
    it "is stale before the first run" do
      expect(described_class.new(profile)).to be_stale
    end

    it "is fresh right after a run" do
      described_class.new(profile).call

      expect(described_class.new(profile.reload)).not_to be_stale
    end

    it "is stale again once the profile swiped another anime" do
      described_class.new(profile).call
      profile.swipes.create!(anime: anime_of(action), liked: true)

      expect(described_class.new(profile.reload)).to be_stale
    end

    it "is stale again once the taste of the profile changed" do
      described_class.new(profile).call
      profile.update!(genre_weights: { "Action" => 0.2 })

      expect(described_class.new(profile.reload)).to be_stale
    end
  end
end
