module Molecules
  # A labelled drop-down list whose first choice is empty, meaning "no filter".
  class SelectFieldComponent < ViewComponent::Base
    def initialize(name:, label:, options:, selected: nil, blank: nil)
      @name = name
      @label = label
      @options = options
      @selected = selected&.to_s
      @blank = blank
      super()
    end

    private

    attr_reader :name, :label, :options, :selected, :blank

    def choices = options.map { |value, label| [ label, value ] }

    def choices = options.map { |value, label| [ label, value ] }

    def input_id = "filter-#{name.to_s.dasherize}"
  end
end
