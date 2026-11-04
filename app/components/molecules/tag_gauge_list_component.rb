module Molecules
  # The tags of an anime as lines with a gauge: the higher the rank, the fuller the gauge.
  class TagGaugeListComponent < ViewComponent::Base
    TONES = %i[magenta cyan].freeze

    def initialize(tags:)
      @tags = tags
      super()
    end

    private

    attr_reader :tags

    def tone_at(index) = TONES[index % TONES.size]
  end
end
