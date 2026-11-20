module Organisms
  # What the app offers besides the recommendations, on the landing page.
  class FeaturesComponent < ViewComponent::Base
    FEATURES = [
      {
        tag: "Watchlist",
        title: "Une seule liste, toutes les plateformes",
        tone: :magenta,
        text: "À voir, en cours, terminé : suis ta progression épisode par épisode."
      },
      {
        tag: "Calendrier",
        title: "Les sorties de la saison au même endroit",
        tone: :cyan,
        text: "Prochain épisode, jour et heure de diffusion, avec tes anime mis en évidence."
      },
      {
        tag: "Tes goûts d'abord",
        title: "La hype passe après toi",
        tone: :magenta,
        text: "La recommandation part de ton profil, pas seulement des titres populaires."
      }
    ].freeze
  end
end
