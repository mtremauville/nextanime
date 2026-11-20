module Molecules
  # A search form that sends its text with a GET, so that a search lives in the address
  # and can be shared, reloaded and paged through.
  class SearchFieldComponent < ViewComponent::Base
    PARAM = "q".freeze

    def initialize(action:, label:, placeholder:, value: nil, hidden: {})
      @action = action
      @label = label
      @placeholder = placeholder
      @value = value
      @hidden = hidden
      super()
    end

    private

    attr_reader :action, :label, :placeholder, :value, :hidden

    def field_id = "search-#{PARAM}"
  end
end
