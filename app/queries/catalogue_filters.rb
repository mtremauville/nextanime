class CatalogueFilters < Data.define(:genre_ids, :formats, :statuses, :season, :year_from, :year_to)
  FORMATS = %w[tv tv_short movie ova ona special].freeze
  STATUSES = %w[finished releasing not_yet_released].freeze
  SEASONS = %w[winter spring summer fall].freeze

  class << self
    def from_params(params)
      source = params || {}
      year_from, year_to = ordered(integer(source[:year_from]), integer(source[:year_to]))

      new(
        genre_ids: texts(source[:genre_ids]).filter_map { |text| positive_integer(text) }.uniq,
        formats: allowed(source[:formats], FORMATS),
        statuses: allowed(source[:statuses], STATUSES),
        season: (source[:season] if SEASONS.include?(source[:season])),
        year_from: year_from,
        year_to: year_to
      )
    end

    private

    def texts(value)
      Array.wrap(value).grep(String)
    end

    def allowed(value, choices)
      texts(value).select { |text| choices.include?(text) }.uniq
    end

    def integer(value)
      return unless value.is_a?(String)

      Integer(value, 10, exception: false)
    end

    def positive_integer(text)
      number = integer(text)
      number if number&.positive?
    end

    def ordered(first, last)
      return [ last, first ] if first && last && first > last

      [ first, last ]
    end
  end

  def active?
    to_query_params.any?
  end

  def to_query_params
    to_h.reject { |_name, value| value.blank? }
  end
end
