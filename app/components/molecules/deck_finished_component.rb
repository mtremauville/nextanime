module Molecules
  # The end of the deck. A member is sent to the recommendations, a visitor is invited to create the
  # account that keeps the swipes and gives access to them.
  class DeckFinishedComponent < ViewComponent::Base
    AUDIENCES = %i[member visitor].freeze

    def initialize(audience:, new_session_href: nil)
      raise ArgumentError, "Unknown audience: #{audience.inspect}" unless AUDIENCES.include?(audience)

      @audience = audience
      @new_session_href = new_session_href
      super()
    end

    private

    attr_reader :new_session_href

    def visitor? = @audience == :visitor

    def title
      I18n.t(new_session_href ? "swipes.finished.session_title" : "swipes.finished.title")
    end

    def text = I18n.t(visitor? ? "swipes.finished.visitor_text" : "swipes.finished.text")

    def link_label = I18n.t(visitor? ? "swipes.finished.visitor_link" : "swipes.finished.link")

    def link_href = visitor? ? new_user_registration_path : recommendations_path
  end
end
