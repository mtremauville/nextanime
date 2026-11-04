module Organisms
  class SwipeDeckComponent < ViewComponent::Base
    def initialize(animes:, completed: 0)
      @animes = animes
      @completed = completed
      super()
    end

    private

    attr_reader :animes, :completed

    # The cards left to swipe plus the ones already swiped before the page loaded.
    def total
      completed + animes.size
    end
  end
end
