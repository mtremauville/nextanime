module Molecules
  # A group of checkboxes that sends the checked choices as a list under one name
  # (formats[]=tv&formats[]=movie). It adds no hidden field: nothing checked, nothing sent.
  # A choice is [ value, label ] or [ value, label, count ]. The :pills variant only changes
  # the look: the choices stay checkboxes, so the keyboard and the form work the same.
  class FilterGroupComponent < ViewComponent::Base
    def initialize(name:, legend:, options:, selected: [], variant: :list)
      @name = name
      @legend = legend
      @options = options
      @selected = selected.map(&:to_s)
      @variant = variant
      super()
    end

    def render? = options.any?

    private

    attr_reader :name, :legend, :options

    def pills? = @variant == :pills

    def checked?(value) = @selected.include?(value.to_s)

    def input_id(value) = "filter-#{name.to_s.dasherize}-#{value.to_s.parameterize}"
  end
end
