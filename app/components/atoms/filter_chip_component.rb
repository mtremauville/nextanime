module Atoms
  # A chosen filter, shown as a pill with a link that removes it.
  class FilterChipComponent < ViewComponent::Base
    def initialize(label:, remove_href:)
      @label = label
      @remove_href = remove_href
      super()
    end

    private

    attr_reader :label, :remove_href
  end
end
