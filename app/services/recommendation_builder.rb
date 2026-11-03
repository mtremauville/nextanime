# Keeps the recommendations of a taste profile up to date: the anime it has not swiped yet,
# scored against its taste, the best ones first in line.
# An explanation already stored on a recommendation survives a new score.
class RecommendationBuilder
  LIMIT = 100
  UNIQUE_KEY = %i[taste_profile_id anime_id].freeze

  def initialize(taste_profile)
    @taste_profile = taste_profile
  end

  def call
    scores = best_scores

    taste_profile.transaction do
      taste_profile.recommendations.where.not(anime_id: scores.keys).delete_all
      save(scores) if scores.any?
    end

    taste_profile.recommendations
  end

  private

  attr_reader :taste_profile

  def best_scores
    scorer = MatchScorer.new(taste_profile)
    scores = candidates.to_h { |anime| [ anime.id, scorer.call(anime) ] }

    scores.max_by(LIMIT) { |_anime_id, score| score }.to_h
  end

  def candidates
    Anime.where.not(id: taste_profile.swiped_anime_ids).includes(:genres, anime_tags: :tag)
  end

  def save(scores)
    rows = scores.map { |anime_id, score| { taste_profile_id: taste_profile.id, anime_id: anime_id, score: score } }

    Recommendation.upsert_all(rows, unique_by: UNIQUE_KEY, update_only: %i[score])
  end
end
