module Molecules
  # A group of checkboxes that sends the checked choices as a list under one name
  # (formats[]=tv&formats[]=movie). It adds no hidden field: nothing checked, nothing sent.
  # A choice is [ value, label ] or [ value, label, count ]. The :pills variant only changes
  # the look: the choices stay checkboxes, so the keyboard and the form work the same.
  # The ids of the checkboxes start with id_prefix, so that the same group can be twice on a page.
  class FilterGroupComponent < ViewComponent::Base
    DEFAULT_ID_PREFIX = "filter".freeze

    def initialize(name:, legend:, options:, selected: [], variant: :list, id_prefix: DEFAULT_ID_PREFIX)
      @name = name
      @legend = legend
      @options = options
      @selected = selected.map(&:to_s)
      @variant = variant
      @id_prefix = id_prefix
      super()
    end

    def render? = options.any?

    private

    attr_reader :name, :legend, :options, :id_prefix

    def pills? = @variant == :pills

    def checked?(value) = @selected.include?(value.to_s)

    def input_id(value) = "#{id_prefix}-#{name.to_s.dasherize}-#{value.to_s.parameterize}"
  end
end
