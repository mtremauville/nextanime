class AnimesController < ApplicationController
  include CurrentTasteProfile

  def index
    taste_profile = existing_taste_profile
    @page = CatalogueQuery.new(page: params[:page]).call
    @scorer = MatchScorer.new(taste_profile) if liked_something?(taste_profile)
  end

  def show
    @anime = Anime.includes(:genres, :main_studio, anime_tags: :tag).find(params[:id])
    @details = AnimeDetails.new(@anime)
    assign_match(existing_taste_profile)
  end

  private

  # Without any like there is nothing to compare the anime with: no match is shown then.
  def liked_something?(taste_profile)
    taste_profile.present? && taste_profile.likes_count.positive?
  end

  def assign_match(taste_profile)
    return unless liked_something?(taste_profile)

    @match_percent = MatchScorer.new(taste_profile).percentage(@anime)
    @reason = MatchExplainer.new(taste_profile).call(@anime)
  end
end
