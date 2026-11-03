class RecommendationsController < ApplicationController
  include CurrentTasteProfile

  DISPLAYED = 24
  TASTE_PILLS = 2
  KINDS = { "series" => %i[tv tv_short ona], "movies" => %i[movie] }.freeze

  # Without any like there is nothing to rank yet: the view then invites to swipe.
  def index
    taste_profile = existing_taste_profile
    @kind = params[:kind] if KINDS.key?(params[:kind])
    @tag_names = names_of(taste_profile&.top_tags(TASTE_PILLS))
    @genre_names = names_of(taste_profile&.top_genres(TASTE_PILLS))
    @recommendations = ranked_recommendations(taste_profile) if recommendable?(taste_profile)
  end

  private

  def names_of(weights) = Array(weights).map(&:first)

  def recommendable?(taste_profile)
    taste_profile.present? && taste_profile.likes_count.positive?
  end

  def ranked_recommendations(taste_profile)
    builder = RecommendationBuilder.new(taste_profile)
    builder.call if builder.stale?

    recommendations = taste_profile.recommendations.preload(anime: [ :genres, :main_studio ])
    formats = KINDS[@kind]
    recommendations = recommendations.joins(:anime).merge(Anime.where(format: formats)) if formats

    recommendations.order(score: :desc, id: :asc).limit(DISPLAYED).to_a
  end
end
