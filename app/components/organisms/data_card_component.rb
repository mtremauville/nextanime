module Organisms
  class DataCardComponent < ViewComponent::Base
    def initialize(export_href:)
      @export_href = export_href
      super()
    end

    private

    attr_reader :export_href
  end
end
