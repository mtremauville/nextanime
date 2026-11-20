module Organisms
  # An example of what the app does, on the landing page. The anime are real but the matches are made up,
  # so the whole block says that it is an example.
  class RecommendationExampleComponent < ViewComponent::Base
    LIKED = {
      key: :death_note,
      title: "Death Note",
      poster: :violet,
      tags: [ "Psychologique", "Thriller", "Ambiance sombre" ]
    }.freeze

    RECOMMENDATIONS = [
      {
        key: :perfect_blue,
        title: "Perfect Blue",
        meta: "Film · 1997 · Madhouse",
        match: 92,
        reason: "Tu aimes les thrillers psychologiques à l'ambiance sombre : celui-ci partage ces thèmes.",
        poster: :violet
      },
      {
        key: :cowboy_bebop,
        title: "Cowboy Bebop",
        meta: "Série · 26 épisodes · Sunrise",
        match: 78,
        reason: "Même ambiance noire et adulte, avec un rythme plus posé.",
        poster: :cyan
      }
    ].freeze

    def initialize(poster_urls: {})
      super()
      @poster_urls = poster_urls
    end

    private

    def liked_image_url
      @poster_urls[LIKED[:key]]
    end

    def recommendation_attributes(recommendation)
      recommendation.except(:key).merge(image_url: @poster_urls[recommendation[:key]])
    end
  end
end
