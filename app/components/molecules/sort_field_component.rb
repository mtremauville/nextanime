module Molecules
  # The "sort by" list of the catalogue. It sends itself as soon as the choice changes and carries
  # the rest of the params (search, filters), so that sorting does not erase them.
  # The match is only offered when it can be told: when the person has liked something.
  class SortFieldComponent < ViewComponent::Base
    FIELD_ID = "sort-field".freeze

    def initialize(action:, selected:, offer_match: false, hidden: {})
      @action = action
      @selected = selected
      @offer_match = offer_match
      @hidden = hidden
      super()
    end

    private

    attr_reader :action, :selected, :hidden

    def choices
      keys = @offer_match ? CatalogueQuery::SORTS : CatalogueQuery::SORTS - [ "match" ]
      keys.map { |key| [ I18n.t("catalogue.sort.#{key}"), key ] }
    end
  end
end
