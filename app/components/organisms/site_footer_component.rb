module Organisms
  # The footer of every page: who runs the site, where the data comes from (as TMDB and JustWatch
  # require) and the pages a person can go to from here.
  class SiteFooterComponent < ViewComponent::Base
    SOURCES = {
      tmdb: "https://www.themoviedb.org/",
      justwatch: "https://www.justwatch.com/",
      anilist: "https://anilist.co/"
    }.freeze
    AUDIENCES = %i[member visitor].freeze

    def initialize(audience:)
      raise ArgumentError, "unknown audience: #{audience.inspect}" unless AUDIENCES.include?(audience)

      @audience = audience
      super()
    end

    private

    attr_reader :audience

    def links
      pages = audience == :member ? member_pages : visitor_pages
      pages.map { |key, path| [ I18n.t("site_footer.links.#{key}"), path ] }
    end

    def member_pages = { discover: discover_path, calendar: calendar_path, watchlist: watchlist_path }

    def visitor_pages = { discover: discover_path, catalogue: catalogue_path }

    def source_link(name, source)
      link_to name, SOURCES.fetch(source), target: "_blank", rel: "noopener noreferrer"
    end
  end
end
