module Tmdb
  # Decides which result of a TMDB search is the given anime, if any.
  # A wrong match would show wrong platforms, so it is strict: the result must be an
  # animation, released the same year (one year apart at most), with the same title.
  class TitleMatcher
    ANIMATION_GENRE_ID = 16
    MAX_YEAR_GAP = 1
    FIELDS = {
      tv: { titles: %w[name original_name], date: "first_air_date" },
      movie: { titles: %w[title original_title], date: "release_date" }
    }.freeze

    def match(anime, results, media_type:)
      fields = FIELDS.fetch(media_type.to_sym)
      year = release_year(anime)
      return unless year

      candidates = results.filter_map do |result|
        gap = year_gap(result, fields.fetch(:date), year)
        [ result, gap ] if gap && animation?(result) && same_title?(anime, result, fields.fetch(:titles))
      end

      candidates.min_by.with_index { |(_result, gap), index| [ gap, index ] }&.first
    end

    private

    def release_year(anime)
      anime.season_year || anime.start_date&.year
    end

    def year_gap(result, date_field, year)
      result_year = Integer(result[date_field].to_s[0, 4], exception: false)
      return unless result_year

      gap = (result_year - year).abs
      gap if gap <= MAX_YEAR_GAP
    end

    def animation?(result)
      Array(result["genre_ids"]).include?(ANIMATION_GENRE_ID)
    end

    def same_title?(anime, result, title_fields)
      result_titles = normalize(title_fields.map { |field| result[field] })

      normalize([ anime.title_english, anime.title_romaji, anime.title_native ]).intersect?(result_titles)
    end

    # Case, punctuation, apostrophes and full-width characters do not make a different title.
    def normalize(titles)
      titles.compact.map { |title| title.unicode_normalize(:nfkc).downcase.gsub(/[^\p{L}\p{N}]/, "") }.reject(&:empty?)
    end
  end
end
