module Organisms
  # The platforms where an anime can be watched in a country, from the best offers to the worst, or
  # the message that there is none. The credit to TMDB and JustWatch is always shown, with the link
  # to the watch page of TMDB when there is one.
  class WhereToWatchComponent < ViewComponent::Base
    def initialize(entries:, country_label:, tmdb_page_url:)
      @entries = entries
      @country_label = country_label
      @tmdb_page_url = tmdb_page_url if tmdb_page_url.to_s.match?(Molecules::PlatformRowComponent::WEB_ADDRESS)
      super()
    end

    private

    attr_reader :entries, :country_label, :tmdb_page_url
  end
end
