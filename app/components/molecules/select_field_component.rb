module Molecules
  # A labelled drop-down list whose first choice is empty, meaning "no filter".
  # Its id starts with id_prefix, so that the same field can be twice on a page.
  class SelectFieldComponent < ViewComponent::Base
    DEFAULT_ID_PREFIX = "filter".freeze

    def initialize(name:, label:, options:, selected: nil, blank: nil, id_prefix: DEFAULT_ID_PREFIX)
      @name = name
      @label = label
      @options = options
      @selected = selected&.to_s
      @blank = blank
      @id_prefix = id_prefix
      super()
    end

    private

    attr_reader :name, :label, :options, :selected, :blank, :id_prefix

    def choices = options.map { |value, label| [ label, value ] }

    def input_id = "#{id_prefix}-#{name.to_s.dasherize}"
  end
end
