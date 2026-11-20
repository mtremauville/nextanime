module Molecules
  class DeckProgressComponent < ViewComponent::Base
    def initialize(completed:, total:)
      unless total.positive? && (0..total).cover?(completed)
        raise ArgumentError, "Completed must be between 0 and #{total}, got #{completed.inspect}"
      end

      @completed = completed
      @total = total
      super()
    end

    private

    attr_reader :completed, :total

    def percent_label
      I18n.t("swipes.progress.percent", percent: percent)
    end

    def percent
      (completed * 100.0 / total).round
    end
  end
end
