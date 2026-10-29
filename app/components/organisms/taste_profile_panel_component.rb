module Organisms
  class TasteProfilePanelComponent < ViewComponent::Base
    def initialize(href: nil)
      @href = href
    end

    private

    attr_reader :href
  end
end
