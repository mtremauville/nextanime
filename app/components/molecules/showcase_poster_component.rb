module Molecules
  # Affiche décorative d'un anime pour la présentation des pages d'authentification.
  class ShowcasePosterComponent < ViewComponent::Base
    POSITIONS = %i[left center right].freeze
    GRADIENTS = %i[violet magenta cyan].freeze

    def initialize(title:, position:, gradient:)
      raise ArgumentError, "Unknown position: #{position.inspect}" unless POSITIONS.include?(position)
      raise ArgumentError, "Unknown gradient: #{gradient.inspect}" unless GRADIENTS.include?(gradient)

      super()
      @title = title
      @position = position
      @gradient = gradient
    end

    private

    attr_reader :title

    def classes
      class_names("na-showcase-poster", "na-showcase-poster--#{@position}", "na-showcase-poster--#{@gradient}")
    end
  end
end
