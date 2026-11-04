class AnimesController < ApplicationController
  include CurrentTasteProfile

  def index
  end

  def show
    @anime = Anime.includes(:genres, :main_studio, anime_tags: :tag).find(params[:id])
    @details = AnimeDetails.new(@anime)
    assign_match(existing_taste_profile)
  end

  private

  # Without any like there is nothing to compare the anime with: the page then shows no match.
  def assign_match(taste_profile)
    return unless taste_profile.present? && taste_profile.likes_count.positive?

    @match_percent = MatchScorer.new(taste_profile).percentage(@anime)
    @reason = MatchExplainer.new(taste_profile).call(@anime)
  end
end
