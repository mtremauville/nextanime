module Molecules
  # Links that narrow a list of results, with a line that sums the list up.
  # A choice is a hash: { label:, href:, current: }.
  class ResultFilterComponent < ViewComponent::Base
    def initialize(label:, choices:, summary:)
      @label = label
      @choices = choices
      @summary = summary
      super()
    end

    private

    attr_reader :label, :choices, :summary

    def choice_class(choice)
      class_names("na-result-filter__choice", "is-current" => choice[:current])
    end
  end
end
