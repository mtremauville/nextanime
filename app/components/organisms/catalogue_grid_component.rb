module Organisms
  # The catalogue as a grid of poster cards. Its id is where "load more" adds the next anime.
  class CatalogueGridComponent < ViewComponent::Base
    DOM_ID = "catalogue-grid".freeze

    def initialize(animes:, scorer: nil)
      @animes = animes
      @scorer = scorer
      super()
    end

    private

    attr_reader :animes, :scorer
  end
end
