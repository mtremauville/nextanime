module Organisms
  # The platforms where an anime can be watched in a country, from the best offers to the worst, or
  # the message that there is none. The credit to TMDB and JustWatch is always shown.
  class WhereToWatchComponent < ViewComponent::Base
    def initialize(entries:, country_label:)
      @entries = entries
      @country_label = country_label
      super()
    end

    private

    attr_reader :entries, :country_label
  end
end
