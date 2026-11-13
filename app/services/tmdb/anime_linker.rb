module Tmdb
  # Links an anime to its TMDB title and remembers the outcome, failures included,
  # so that the titles TMDB does not know are not searched again at every run.
  class AnimeLinker
    def initialize(client:, matcher: TitleMatcher.new)
      @client = client
      @matcher = matcher
    end

    def link(anime)
      existing = anime.tmdb_match
      return existing if existing&.matched?

      media_type = media_type_for(anime)
      result = find_result(anime, media_type)

      (existing || anime.build_tmdb_match).tap do |match|
        match.update!(tmdb_id: result&.fetch("id"), media_type: result && media_type, checked_at: Time.current)
      end
    end

    private

    def media_type_for(anime)
      anime.format_movie? ? :movie : :tv
    end

    # The titles are tried in order and the search stops at the first match.
    def find_result(anime, media_type)
      matches = titles(anime).lazy.filter_map { |title| match_for(anime, title, media_type) }
      matches.first
    end

    def match_for(anime, title, media_type)
      @matcher.match(anime, @client.search(media_type: media_type, query: title), media_type: media_type)
    end

    def titles(anime)
      [ anime.title_english, anime.title_romaji ].compact_blank.uniq
    end
  end
end
