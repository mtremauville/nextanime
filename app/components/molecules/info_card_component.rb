module Molecules
  # The facts about an anime as label and value pairs, in the order they come.
  class InfoCardComponent < ViewComponent::Base
    def initialize(rows:)
      @rows = rows
      super()
    end

    private

    attr_reader :rows
  end
end
