module Organisms
  class DataCardComponent < ViewComponent::Base
    def initialize(export_href:, delete_href:)
      @export_href = export_href
      @delete_href = delete_href
      super()
    end

    private

    attr_reader :export_href, :delete_href
  end
end
