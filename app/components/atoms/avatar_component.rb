module Atoms
  class AvatarComponent < ViewComponent::Base
    PLACEHOLDER = "?".freeze

    def initialize(name:)
      @name = name
      super()
    end

    def call
      tag.span(initial, class: "na-avatar", aria: { hidden: true })
    end

    private

    def initial
      @name.to_s.strip.first.to_s.upcase.presence || PLACEHOLDER
    end
  end
end
