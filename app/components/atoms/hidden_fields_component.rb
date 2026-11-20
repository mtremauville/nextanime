module Atoms
  # Hidden inputs that carry the rest of the params through a GET form, so that changing one
  # thing (the search, a filter, the sort) does not erase the others. A list is sent as name[].
  class HiddenFieldsComponent < ViewComponent::Base
    def initialize(fields: {})
      @fields = fields
      super()
    end

    def render? = pairs.any?

    private

    attr_reader :fields

    # One [name, value] pair for each hidden input.
    def pairs
      @pairs ||= fields.flat_map do |name, value|
        Array.wrap(value).reject(&:blank?).map { |item| [ value.is_a?(Array) ? "#{name}[]" : name, item ] }
      end
    end
  end
end
