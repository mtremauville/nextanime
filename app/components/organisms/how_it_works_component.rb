module Organisms
  # The three steps from the taste of the visitor to the recommendations, on the landing page.
  class HowItWorksComponent < ViewComponent::Base
    STEPS = [
      {
        title: "Swipe tes références",
        tone: :magenta,
        text: "Tu likes, tu passes. En quelques cartes, on repère les genres, ambiances et univers qui te parlent."
      },
      {
        title: "On cerne ta vibe",
        tone: :cyan,
        text: "NextAnime dessine ton profil de goûts à partir de tes choix, avec les tags les plus marqués."
      },
      {
        title: "Trouve ton match",
        tone: :magenta,
        text: "Des recommandations classées par pourcentage de match, avec la raison du match en une phrase."
      }
    ].freeze
  end
end
