module Molecules
  # A card that says there is nothing to show here, and where to go from there.
  class EmptyStateComponent < ViewComponent::Base
    def initialize(title:, text:, link_label:, link_href:, link_variant: :primary)
      @title = title
      @text = text
      @link_label = link_label
      @link_href = link_href
      @link_variant = link_variant
      super()
    end

    private

    attr_reader :title, :text, :link_label, :link_href, :link_variant
  end
end
