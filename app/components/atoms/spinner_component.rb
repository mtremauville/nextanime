module Atoms
  # A ring that turns while something loads. It is decoration: the busy state is announced by the
  # element that holds it (aria-busy), so assistive technologies skip the ring.
  class SpinnerComponent < ViewComponent::Base
    SIZES = %i[regular small].freeze
    TONES = %i[cyan magenta dark].freeze

    def initialize(size: :regular, tone: :cyan)
      raise ArgumentError, "Unknown size: #{size.inspect}" unless SIZES.include?(size)
      raise ArgumentError, "Unknown tone: #{tone.inspect}" unless TONES.include?(tone)

      @size = size
      @tone = tone
      super()
    end

    def call
      tag.span(class: css_classes, aria: { hidden: true })
    end

    private

    def css_classes
      class_names("na-spinner", "na-spinner--small": @size == :small, "na-spinner--#{@tone}": @tone != :cyan)
    end
  end
end
