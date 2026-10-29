module Molecules
  class SwipeCardComponent < ViewComponent::Base
    MAX_GENRES = 3

    def initialize(anime:)
      @anime = anime
      super()
    end

    private

    attr_reader :anime

    def badge
      parts = [ format_label, anime.start_date&.year ].compact
      parts.join(" · ") if parts.any?
    end

    def meta
      parts = [ anime.main_studio&.name, episodes_label ].compact
      parts.join(" · ") if parts.any?
    end

    def genre_labels
      anime.genres.first(MAX_GENRES).map(&:name)
    end

    def format_label
      I18n.t("animes.formats.#{anime.format}") if anime.format
    end

    def episodes_label
      I18n.t("animes.episodes", count: anime.episodes) if anime.episodes
    end
  end
end
