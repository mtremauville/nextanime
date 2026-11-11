module Organisms
  # The cards of the catalogue as list items, to put in a list or to add to one with a turbo stream.
  # It makes no query: the genres and the studio of each anime are loaded beforehand.
  # The match only shows with a scorer, that is when the visitor has a taste profile.
  class CatalogueItemsComponent < ViewComponent::Base
    def initialize(animes:, scorer: nil, listed_ids: Set.new)
      @animes = animes
      @scorer = scorer
      @listed_ids = listed_ids
      super()
    end

    private

    attr_reader :animes, :scorer, :listed_ids

    def summary_for(anime) = AnimeSummary.new(anime)
  end
end
