module Organisms
  # The promise of the landing page: what the app does and the two ways to try it.
  class HeroComponent < ViewComponent::Base
    def initialize(poster_urls: {})
      super()
      @poster_urls = poster_urls
    end

    private

    attr_reader :poster_urls
  end
end
