module Atoms
  class MatchBadgeComponent < ViewComponent::Base
    RANGE = (0..100)

    def initialize(percent:)
      raise ArgumentError, "Percent must be between 0 and 100, got #{percent.inspect}" unless RANGE.cover?(percent)

      @percent = percent.round
      super()
    end

    def call
      tag.span(class: "na-badge-match") do
        safe_join([
          tag.span("#{@percent}%", aria: { hidden: true }),
          tag.span("Correspondance de #{@percent} %", class: "visually-hidden")
        ])
      end
    end
  end
end
