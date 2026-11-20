module Organisms
  # The recommendations as a grid of poster cards, in the order they come.
  # It makes no query: the genres and the studio of each anime are loaded beforehand, as are the platforms.
  class RecommendationGridComponent < ViewComponent::Base
    def initialize(recommendations:, explainer: nil, platforms_by_anime: {})
      @recommendations = recommendations
      @explainer = explainer
      @platforms_by_anime = platforms_by_anime
      super()
    end

    private

    attr_reader :recommendations, :explainer, :platforms_by_anime

    def summary_for(anime) = AnimeSummary.new(anime)
  end
end
