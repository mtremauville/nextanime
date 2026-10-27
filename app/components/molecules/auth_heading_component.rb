module Molecules
  # Titre et sous-titre en haut de la carte d'authentification.
  class AuthHeadingComponent < ViewComponent::Base
    def initialize(title:, subtitle: nil)
      super()
      @title = title
      @subtitle = subtitle
    end

    private

    attr_reader :title, :subtitle
  end
end
