module Organisms
  # An example of what the app does, on the landing page. The anime are real but the matches are made up,
  # so the whole block says that it is an example.
  class RecommendationExampleComponent < ViewComponent::Base
    LIKED = {
      title: "Death Note",
      poster: :violet,
      tags: [ "Psychologique", "Thriller", "Ambiance sombre" ]
    }.freeze

    RECOMMENDATIONS = [
      {
        title: "Perfect Blue",
        meta: "Film · 1997 · Madhouse",
        match: 92,
        reason: "Tu aimes les thrillers psychologiques à l'ambiance sombre : celui-ci partage ces thèmes.",
        poster: :violet
      },
      {
        title: "Cowboy Bebop",
        meta: "Série · 26 épisodes · Sunrise",
        match: 78,
        reason: "Même ambiance noire et adulte, avec un rythme plus posé.",
        poster: :cyan
      }
    ].freeze
  end
end
