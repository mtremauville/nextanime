module Molecules
  # One numbered step of the explanation on the landing page.
  class StepCardComponent < ViewComponent::Base
    TONES = %i[magenta cyan].freeze
    NUMBER_WIDTH = 2

    def initialize(number:, title:, tone:)
      raise ArgumentError, "Unknown tone: #{tone.inspect}" unless TONES.include?(tone)

      super()
      @number = number
      @title = title
      @tone = tone
    end

    private

    attr_reader :title

    def formatted_number
      @number.to_s.rjust(NUMBER_WIDTH, "0")
    end

    def classes
      class_names("na-step", "na-step--#{@tone}")
    end
  end
end
