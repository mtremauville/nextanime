class AnimesController < ApplicationController
  include CurrentTasteProfile

  helper_method :catalogue_page_path

  def index
    taste_profile = existing_taste_profile
    @search = search_text
    @filters = CatalogueFilters.from_params(params)
    @genres = Genre.order(:name)
    @genre_counts = AnimeGenre.group(:genre_id).count
    @scorer = MatchScorer.new(taste_profile) if liked_something?(taste_profile)
    @requested_sort = sort_choice
    @sort = @requested_sort || default_sort
    @page = CatalogueQuery.new(page: params[:page], search: @search, filters: @filters, sort: @sort, scorer: @scorer).call
  end

  def show
    @anime = Anime.includes(:genres, :main_studio, anime_tags: :tag).find(params[:id])
    @details = AnimeDetails.new(@anime)
    assign_match(existing_taste_profile)
  end

  private

  # The one place that builds the address of a page of the catalogue, so that the pagination
  # and the "load more" link both keep the search that is under way.
  def catalogue_page_path(number) = catalogue_path(page: number, q: @search.presence, sort: @requested_sort, **@filters.to_query_params)

  # Only a text is a search: anything else sent as q, an array for instance, is ignored.
  def search_text
    text = params[:q]
    text.is_a?(String) ? text.strip : ""
  end

  # Only a sort that can be offered is kept: anything else, an array for instance, is ignored.
  def sort_choice
    requested = params[:sort]
    requested if requested.is_a?(String) && CatalogueQuery.sorts(match: @scorer.present?).include?(requested)
  end

  # The closest match first for whoever has liked something, the most popular otherwise.
  def default_sort = @scorer ? "match" : "popularity"

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
