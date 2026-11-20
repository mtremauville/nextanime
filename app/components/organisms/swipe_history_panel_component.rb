module Organisms
  # What the swipes lead to. A member is sent to the recommendations, a visitor is invited to create
  # the account that keeps the swipes and gives access to them.
  class SwipeHistoryPanelComponent < ViewComponent::Base
    AUDIENCES = %i[member visitor].freeze

    def initialize(audience:)
      raise ArgumentError, "Unknown audience: #{audience.inspect}" unless AUDIENCES.include?(audience)

      @audience = audience
    end

    private

    def visitor? = @audience == :visitor

    def callout = I18n.t(visitor? ? "swipes.history.visitor_callout" : "swipes.history.callout")

    def link_label = I18n.t(visitor? ? "swipes.history.visitor_link" : "swipes.history.link")

    def link_href = visitor? ? new_user_registration_path : recommendations_path
  end
end
