module Organisms
  # The filters of the catalogue, in a form that sends them with a GET. The search under way
  # rides along in a hidden field, so that filtering does not erase it.
  class CatalogueFiltersComponent < ViewComponent::Base
    def initialize(action:, filters:, genres:, search: nil)
      @action = action
      @filters = filters
      @genres = genres
      @search = search
      super()
    end

    private

    attr_reader :action, :filters, :genres, :search

    def genre_options = genres.map { |genre| [ genre.id, genre.name ] }

    def format_options = named("animes.formats", CatalogueFilters::FORMATS)

    def status_options = named("animes.statuses", CatalogueFilters::STATUSES)

    def season_options = named("animes.seasons", CatalogueFilters::SEASONS)

    def named(scope, keys) = keys.map { |key| [ key, I18n.t("#{scope}.#{key}") ] }
  end
end
