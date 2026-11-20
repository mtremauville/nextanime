module Molecules
  # One of the features that the landing page lists: a label, a title and a sentence.
  class FeatureCardComponent < ViewComponent::Base
    TONES = %i[magenta cyan].freeze

    def initialize(tag:, title:, tone:)
      raise ArgumentError, "Unknown tone: #{tone.inspect}" unless TONES.include?(tone)

      super()
      @tag_label = tag
      @title = title
      @tone = tone
    end

    private

    attr_reader :tag_label, :title

    def classes
      class_names("na-feature", "na-feature--#{@tone}")
    end
  end
end
