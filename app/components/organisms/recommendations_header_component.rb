module Organisms
  # The top of the recommendations page: what it is, the taste it comes from,
  # and the way back to swiping. Tags and genres are names, the strongest ones first.
  class RecommendationsHeaderComponent < ViewComponent::Base
    def initialize(tags:, genres:, swipe_href:, profile_href: nil)
      @tags = tags
      @genres = genres
      @swipe_href = swipe_href
      @profile_href = profile_href
      super()
    end

    private

    attr_reader :tags, :genres, :swipe_href, :profile_href
  end
end
