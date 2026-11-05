module Molecules
  # The filters under way, as a row of chips. A chip is a hash: { label:, href: }, the href being
  # the catalogue without that filter. Nothing is drawn when no filter is active.
  class ActiveFiltersComponent < ViewComponent::Base
    def initialize(chips:)
      @chips = chips
      super()
    end

    def render? = chips.any?

    private

    attr_reader :chips
  end
end
