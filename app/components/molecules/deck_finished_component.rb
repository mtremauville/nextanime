module Molecules
  class DeckFinishedComponent < ViewComponent::Base
    def initialize(recommendations_href:, new_session_href: nil)
      @recommendations_href = recommendations_href
      @new_session_href = new_session_href
      super()
    end

    private

    attr_reader :recommendations_href, :new_session_href

    def title
      I18n.t(new_session_href ? "swipes.finished.session_title" : "swipes.finished.title")
    end
  end
end
