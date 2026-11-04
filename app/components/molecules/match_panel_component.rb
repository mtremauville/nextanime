module Molecules
  # The score of an anime for a taste profile, and the reason of it when there is one.
  class MatchPanelComponent < ViewComponent::Base
    def initialize(percent:, reason: nil)
      @percent = percent
      @reason = reason
      super()
    end

    private

    attr_reader :percent, :reason
  end
end
