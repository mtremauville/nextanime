module Atoms
  class TagComponent < ViewComponent::Base
    TONES = {
      magenta: "na-tag",
      cyan: "na-tag na-tag--cyan",
      muted: "na-tag na-tag--muted"
    }.freeze

    def initialize(label:, tone: :magenta)
      raise ArgumentError, "Unknown tone: #{tone.inspect}" unless TONES.key?(tone)

      @label = label
      @tone = tone
      super()
    end

    def call
      tag.span(@label, class: TONES.fetch(@tone))
    end
  end
end
