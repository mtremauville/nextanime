module Organisms
  # The taste of a person as bars of genres and pills of tags.
  # It only displays what it is given: genres and tags are [name, weight] pairs.
  class TasteProfileCardComponent < ViewComponent::Base
    TONES = %i[magenta cyan].freeze

    def initialize(genres:, tags:, swipes_count:, swipe_href:, reset_href:)
      @genres = genres
      @tags = tags
      @swipes_count = swipes_count
      @swipe_href = swipe_href
      @reset_href = reset_href
      super()
    end

    private

    attr_reader :genres, :tags, :swipes_count, :swipe_href, :reset_href

    def without_taste? = genres.empty? && tags.empty?

    def tone_at(index) = TONES[index % TONES.size]

    def percentage(weight) = (weight * 100).round
  end
end
