module Organisms
  # The recommendations as a grid of poster cards, in the order they come.
  # It makes no query: the genres and the studio of each anime are loaded beforehand.
  class RecommendationGridComponent < ViewComponent::Base
    def initialize(recommendations:)
      @recommendations = recommendations
      super()
    end

    private

    attr_reader :recommendations

    def summary_for(anime) = AnimeSummary.new(anime)
  end
end
