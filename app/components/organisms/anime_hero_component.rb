module Organisms
  # The top of the page of an anime: banner, cover, what it is, its title and genres and,
  # when the person has a taste profile, how well the anime matches it.
  class AnimeHeroComponent < ViewComponent::Base
    renders_one :actions

    def initialize(anime:, details:, match_percent: nil, reason: nil)
      @anime = anime
      @details = details
      @match_percent = match_percent
      @reason = reason
      super()
    end

    private

    attr_reader :anime, :details, :match_percent, :reason
  end
end
