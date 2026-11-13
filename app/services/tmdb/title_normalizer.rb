module Tmdb
  # Brings the titles of AniList and TMDB to a form that can be compared:
  # the same title is not always written the same way on both sides.
  module TitleNormalizer
    LATIN_ACCENTS = /[\u0300-\u036f]/
    QUALIFIER = /\s*\([^)]*\)/
    MOVIE_MARKERS = /\bthe movie\b|映画|劇場版/
    NOT_A_LETTER_OR_DIGIT = /[^\p{L}\p{N}]/
    SEASON_MARKERS = /
      (?:\s+(?:
        Season\s*\d+ | \d+(?:st|nd|rd|th)\s+Season | Final\s+Season | Part\s*\d+ | Cour\s*\d+ | [IVX]+ | [2-9]
      ))+\z
    /xi

    def self.normalize(title)
      unaccented = title.unicode_normalize(:nfkd).gsub(LATIN_ACCENTS, "").unicode_normalize(:nfkc)

      unaccented.downcase.tr("×", "x").gsub(QUALIFIER, "").gsub(MOVIE_MARKERS, "").gsub(NOT_A_LETTER_OR_DIGIT, "")
    end

    # TMDB finds nothing for a title that ends with "(TV)" or "(2011)".
    def self.search_term(title)
      title.unicode_normalize(:nfkc).gsub(QUALIFIER, "").strip
    end

    # TMDB has one series for all the seasons of an anime: "Attack on Titan Season 3" is found as "Attack on Titan".
    def self.series_title(title)
      title.sub(SEASON_MARKERS, "").strip
    end
  end
end
