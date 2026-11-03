class RecommendationsController < ApplicationController
  include CurrentTasteProfile

  DISPLAYED = 24
  KINDS = { "series" => %i[tv tv_short ona], "movies" => %i[movie] }.freeze

  # Without any like there is nothing to rank yet: the view then invites to swipe.
  def index
    taste_profile = existing_taste_profile
    @recommendations = ranked_recommendations(taste_profile) if recommendable?(taste_profile)
  end

  private

  def recommendable?(taste_profile)
    taste_profile.present? && taste_profile.likes_count.positive?
  end

  def ranked_recommendations(taste_profile)
    builder = RecommendationBuilder.new(taste_profile)
    builder.call if builder.stale?

    recommendations = taste_profile.recommendations.includes(:anime)
    formats = KINDS[params[:kind]]
    recommendations = recommendations.joins(:anime).merge(Anime.where(format: formats)) if formats

    recommendations.order(score: :desc, id: :asc).limit(DISPLAYED)
  end
end
