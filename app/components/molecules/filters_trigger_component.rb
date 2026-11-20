module Molecules
  # The button of a phone that opens the filters. It tells how many filters are active, and says
  # nothing when there is none. controls is the id of the dialog it opens.
  class FiltersTriggerComponent < ViewComponent::Base
    def initialize(count:, controls:)
      @count = count
      @controls = controls
      super()
    end

    private

    attr_reader :count, :controls
  end
end
