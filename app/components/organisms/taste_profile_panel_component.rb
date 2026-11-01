module Organisms
  class TasteProfilePanelComponent < ViewComponent::Base
    def initialize(href: nil, label: I18n.t("swipes.taste_profile.link"), reset_href: nil)
      @href = href
      @label = label
      @reset_href = reset_href
    end

    private

    attr_reader :href, :label, :reset_href
  end
end
