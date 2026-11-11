module Organisms
  # The catalogue as a grid of poster cards. Its id is where "load more" adds the next anime.
  class CatalogueGridComponent < ViewComponent::Base
    DOM_ID = "catalogue-grid".freeze

    def initialize(animes:, scorer: nil, listed_ids: Set.new)
      @animes = animes
      @scorer = scorer
      @listed_ids = listed_ids
      super()
    end

    private

    attr_reader :animes, :scorer, :listed_ids
  end
end
