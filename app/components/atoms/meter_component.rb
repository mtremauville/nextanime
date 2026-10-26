module Atoms
  class MeterComponent < ViewComponent::Base
    RANGE = (0..100)
    TONES = { magenta: nil, cyan: "na-meter__fill--cyan" }.freeze

    def initialize(value:, label:, tone: :magenta)
      raise ArgumentError, "Value must be between 0 and 100, got #{value.inspect}" unless RANGE.cover?(value)
      raise ArgumentError, "Unknown tone: #{tone.inspect}" unless TONES.key?(tone)

      @value = value.round
      @label = label
      @tone = tone
      super()
    end

    def call
      tag.div(class: "na-meter", role: "progressbar", aria: aria_attributes) do
        tag.span(class: class_names("na-meter__fill", "na-meter__fill--#{@value}", TONES.fetch(@tone)))
      end
    end

    private

    def aria_attributes
      { valuenow: @value, valuemin: RANGE.min, valuemax: RANGE.max, label: @label }
    end
  end
end
