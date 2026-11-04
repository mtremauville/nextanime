module Organisms
  # The side panel of the swipe page: the genres and the tags the person loves so far,
  # each one with a gauge, and the way to the full profile.
  class TasteProfilePanelComponent < ViewComponent::Base
    TONES = { genre: :magenta, tag: :cyan }.freeze

    def initialize(href: nil, label: I18n.t("swipes.taste_profile.link"), tastes: [])
      @href = href
      @label = label
      @tastes = tastes
    end

    private

    attr_reader :href, :label, :tastes

    def tone_for(taste) = TONES.fetch(taste.kind)

    def percentage(taste) = (taste.weight * 100).round
  end
end
