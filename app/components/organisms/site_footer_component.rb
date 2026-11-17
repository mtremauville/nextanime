module Organisms
  # The footer of every page. It names the sources of the data, as TMDB and JustWatch require.
  class SiteFooterComponent < ViewComponent::Base
    SOURCES = {
      tmdb: "https://www.themoviedb.org/",
      justwatch: "https://www.justwatch.com/",
      anilist: "https://anilist.co/"
    }.freeze

    private

    def source_link(name, source)
      link_to name, SOURCES.fetch(source), target: "_blank", rel: "noopener noreferrer"
    end
  end
end
