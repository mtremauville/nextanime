module Molecules
  # Affiche décorative d'un anime pour la présentation des pages d'authentification.
  # Sans couverture, elle garde son dégradé.
  class ShowcasePosterComponent < ViewComponent::Base
    POSITIONS = %i[left center right].freeze
    GRADIENTS = %i[violet magenta cyan].freeze

    def initialize(title:, position:, gradient:, image_url: nil)
      raise ArgumentError, "Unknown position: #{position.inspect}" unless POSITIONS.include?(position)
      raise ArgumentError, "Unknown gradient: #{gradient.inspect}" unless GRADIENTS.include?(gradient)

      super()
      @title = title
      @position = position
      @gradient = gradient
      @image_url = image_url
    end

    private

    attr_reader :title, :image_url

    def classes
      class_names("na-showcase-poster", "na-showcase-poster--#{@position}", "na-showcase-poster--#{@gradient}")
    end
  end
end
