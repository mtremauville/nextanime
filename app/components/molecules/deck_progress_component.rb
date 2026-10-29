module Molecules
  class DeckProgressComponent < ViewComponent::Base
    def initialize(position:, total:)
      unless (1..total).cover?(position)
        raise ArgumentError, "Position must be between 1 and #{total}, got #{position.inspect}"
      end

      @position = position
      @total = total
      super()
    end

    private

    attr_reader :position, :total

    def position_label
      I18n.t("swipes.progress.position", position: position, total: total)
    end

    def remaining_label
      remaining = total - position
      return I18n.t("swipes.progress.last") if remaining.zero?

      I18n.t("swipes.progress.remaining", remaining: remaining)
    end

    def percent
      (position * 100.0 / total).round
    end
  end
end
