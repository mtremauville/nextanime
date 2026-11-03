module Organisms
  class TasteProfilePanelComponent < ViewComponent::Base
    def initialize(href: nil, label: I18n.t("swipes.taste_profile.link"))
      @href = href
      @label = label
    end

    private

    attr_reader :href, :label
  end
end
