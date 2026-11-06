module Organisms
  # The filters of the catalogue, in a form that sends them with a GET. The search and the sort
  # under way ride along in hidden fields, so that filtering does not erase them.
  # genre_counts maps a genre id to the number of anime it has; without it no count is shown.
  # In the column (the default) the form sends itself at each change. As a :sheet, for the bottom
  # sheet of a phone, every group is a row of pills without counts, the form is sent by its button,
  # and the ids carry their own prefix so that they never double those of the column.
  class CatalogueFiltersComponent < ViewComponent::Base
    ID_PREFIXES = { column: "filter", sheet: "sheet-filter" }.freeze

    def initialize(action:, filters:, genres:, search: nil, sort: nil, genre_counts: nil, variant: :column)
      @action = action
      @filters = filters
      @genres = genres
      @search = search
      @sort = sort
      @genre_counts = genre_counts
      @variant = variant
      @id_prefix = ID_PREFIXES.fetch(variant)
      super()
    end

    private

    attr_reader :action, :filters, :genres, :search, :sort, :genre_counts, :id_prefix

    def sheet? = @variant == :sheet

    def wrapper_tag = sheet? ? :div : :aside

    def wrapper_label = (I18n.t("catalogue.filters.title") unless sheet?)

    def group_variant = sheet? ? :pills : :list

    def form_data = sheet? ? {} : { controller: "auto-submit", action: "change->auto-submit#submit" }

    def genre_options = genres.map { |genre| [ genre.id, genre.name, count_of(genre) ] }

    def format_options = named("animes.formats", CatalogueFilters::FORMATS)

    def status_options = named("catalogue.filters.statuses", CatalogueFilters::STATUSES)

    def season_options = named("animes.seasons", CatalogueFilters::SEASONS)

    def named(scope, keys) = keys.map { |key| [ key, I18n.t("#{scope}.#{key}") ] }

    def count_of(genre)
      genre_counts.fetch(genre.id, 0) if genre_counts && !sheet?
    end

    # What a change of filters must not lose: the search and the sort.
    def carried
      { Molecules::SearchFieldComponent::PARAM => search.presence, sort: sort.presence }.compact
    end

    # Resetting clears the filters but keeps the search and the sort.
    def reset_path
      carried.empty? ? action : "#{action}?#{carried.to_query}"
    end
  end
end
