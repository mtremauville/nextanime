module Molecules
  # How much of the catalogue is shown, and the way to load the next anime on a small screen.
  # The link asks for a turbo stream: the answer adds the anime to the grid and replaces this block.
  class LoadMoreComponent < ViewComponent::Base
    DOM_ID = "load-more".freeze
    FULL = 100.0

    def initialize(shown:, total:, next_url: nil)
      @shown = shown
      @total = total
      @next_url = next_url
      super()
    end

    def render? = total.positive?

    private

    attr_reader :shown, :total, :next_url

    def percent = shown * FULL / total
  end
end
