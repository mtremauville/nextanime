module Molecules
  # A group of checkboxes that sends the checked choices as a list under one name
  # (formats[]=tv&formats[]=movie). It adds no hidden field: nothing checked, nothing sent.
  class FilterGroupComponent < ViewComponent::Base
    def initialize(name:, legend:, options:, selected: [])
      @name = name
      @legend = legend
      @options = options
      @selected = selected.map(&:to_s)
      super()
    end

    def render? = options.any?

    private

    attr_reader :name, :legend, :options

    def checked?(value) = @selected.include?(value.to_s)

    def input_id(value) = "filter-#{name.to_s.dasherize}-#{value.to_s.parameterize}"
  end
end
