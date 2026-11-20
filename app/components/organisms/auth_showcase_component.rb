module Organisms
  # Trois affiches inclinées, purement décoratives, à côté du formulaire d'authentification et dans l'accueil.
  # Une affiche dont la couverture n'est pas donnée garde son dégradé.
  class AuthShowcaseComponent < ViewComponent::Base
    POSTERS = [
      { key: :perfect_blue, title: "Perfect Blue", position: :left, gradient: :violet },
      { key: :chainsaw_man, title: "Chainsaw Man", position: :center, gradient: :magenta },
      { key: :eighty_six, title: "Eighty-Six", position: :right, gradient: :cyan }
    ].freeze

    def initialize(image_urls: {})
      super()
      @image_urls = image_urls
    end

    private

    def poster_attributes(poster)
      poster.except(:key).merge(image_url: @image_urls[poster[:key]])
    end
  end
end
