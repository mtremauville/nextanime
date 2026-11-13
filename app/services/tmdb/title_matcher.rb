module Tmdb
  # Decides which result of a TMDB search is the given anime, if any.
  # A wrong match would show wrong platforms, so it is strict. The result must be an animation and
  # either have the same title and come out the same year (one year apart at most), or, for a series,
  # be the Japanese series whose later season or arc the anime is.
  class TitleMatcher
    ANIMATION_GENRE_ID = 16
    JAPAN = "JP".freeze
    MAX_YEAR_GAP = 1
    MAX_SEQUEL_YEAR_GAP = 10
    MIN_SEQUEL_TITLE_LENGTH = 4
    FIELDS = {
      tv: { titles: %w[name original_name], date: "first_air_date" },
      movie: { titles: %w[title original_title], date: "release_date" }
    }.freeze

    def match(anime, results, media_type:)
      media_type = media_type.to_sym
      fields = FIELDS.fetch(media_type)
      year = release_year(anime)
      return unless year

      animations = results.select { |result| animation?(result) }
      titles = normalize([ anime.title_english, anime.title_romaji, anime.title_native ])

      same_title(animations, fields, year, titles) || (later_season(animations, fields, year, titles) if media_type == :tv)
    end

    private

    def release_year(anime)
      anime.season_year || anime.start_date&.year
    end

    def same_title(results, fields, year, titles)
      closest(results) do |result|
        result_year = release_year_of(result, fields)
        next unless result_year

        gap = (result_year - year).abs
        gap if gap <= MAX_YEAR_GAP && titles_of(result, fields).intersect?(titles)
      end
    end

    # The series started before the anime, which is one of its later seasons or arcs.
    def later_season(results, fields, year, titles)
      closest(results) do |result|
        result_year = release_year_of(result, fields)
        next unless result_year

        gap = year - result_year
        gap if gap.between?(0, MAX_SEQUEL_YEAR_GAP) && japanese?(result) && begins_the_title?(titles_of(result, fields), titles)
      end
    end

    # The title of the series is the start of the title of the anime, which is longer.
    def begins_the_title?(series_titles, anime_titles)
      series_titles.any? do |series_title|
        series_title.length >= MIN_SEQUEL_TITLE_LENGTH &&
          anime_titles.any? { |title| title.start_with?(series_title) && title.length > series_title.length }
      end
    end

    # The block gives the gap of a result, or nothing when it does not qualify. The closest year
    # wins, then the most relevant result of the search.
    def closest(results)
      candidates = results.filter_map do |result|
        gap = yield(result)
        [ result, gap ] if gap
      end

      candidates.min_by.with_index { |(_result, gap), index| [ gap, index ] }&.first
    end

    def release_year_of(result, fields)
      Integer(result[fields.fetch(:date)].to_s[0, 4], exception: false)
    end

    def animation?(result)
      Array(result["genre_ids"]).include?(ANIMATION_GENRE_ID)
    end

    def japanese?(result)
      Array(result["origin_country"]).include?(JAPAN)
    end

    def titles_of(result, fields)
      normalize(fields.fetch(:titles).map { |field| result[field] })
    end

    def normalize(titles)
      titles.compact.map { |title| TitleNormalizer.normalize(title) }.reject(&:empty?)
    end
  end
end
