module Organisms
  # Trois affiches inclinées, purement décoratives, à côté du formulaire d'authentification.
  class AuthShowcaseComponent < ViewComponent::Base
    POSTERS = [
      { title: "Perfect Blue", position: :left, gradient: :violet },
      { title: "Chainsaw Man", position: :center, gradient: :magenta },
      { title: "Eighty-Six", position: :right, gradient: :cyan }
    ].freeze
  end
end
