module Tmdb
  # Imports the availabilities of a list of anime and reports how it went.
  # A TMDB failure on one anime does not stop the others.
  class AvailabilitySync
    DEFAULT_LIMIT = 100

    Failure = Data.define(:anime, :error)

    Report = Data.define(:matched, :unmatched, :failed) do
      def total
        matched.size + unmatched.size + failed.size
      end

      # Failures say nothing about the quality of the matching, so they are left out.
      def match_rate
        tried = matched.size + unmatched.size
        return if tried.zero?

        (matched.size * 100.0 / tried).round(1)
      end

      def to_s
        lines = [ "#{total} anime processed: #{matched.size} matched, #{unmatched.size} not matched, #{failed.size} failed" ]
        lines << "Match rate: #{match_rate} %" if match_rate
        lines.concat(section("Not matched", unmatched.map { |anime| "#{anime.display_title} (AniList #{anime.anilist_id})" }))
        lines.concat(section("Failed", failed.map { |failure| "#{failure.anime.display_title}: #{failure.error.message}" }))
        lines.join("\n")
      end

      private

      def section(title, entries)
        return [] if entries.empty?

        [ "#{title}:", *entries.map { |entry| "  - #{entry}" } ]
      end
    end

    def initialize(importer: AvailabilityImporter.new(client: Client.new))
      @importer = importer
    end

    def call(animes)
      matched = []
      unmatched = []
      failed = []

      animes.each do |anime|
        (@importer.import(anime).matched? ? matched : unmatched) << anime
      rescue Error => error
        failed << Failure.new(anime: anime, error: error)
      end

      Report.new(matched: matched, unmatched: unmatched, failed: failed)
    end
  end
end
