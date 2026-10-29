module Organisms
  class SwipeDeckComponent < ViewComponent::Base
    def initialize(animes:)
      @animes = animes
      super()
    end

    private

    attr_reader :animes
  end
end
