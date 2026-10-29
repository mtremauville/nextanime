module Organisms
  class SwipeHistoryPanelComponent < ViewComponent::Base
    def initialize(recommendations_href:)
      @recommendations_href = recommendations_href
    end

    private

    attr_reader :recommendations_href
  end
end
