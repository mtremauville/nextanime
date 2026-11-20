module Atoms
  # The logo of a streaming platform, or its initials when TMDB gave none. The name of the platform
  # is always written next to it (or listed for screen readers), so the logo is decorative.
  class PlatformLogoComponent < ViewComponent::Base
    SIZES = { regular: 44, small: 24 }.freeze
    MAX_INITIALS = 3

    def initialize(platform:, size: :regular)
      raise ArgumentError, "Unknown size: #{size.inspect}" unless SIZES.key?(size)

      @platform = platform
      @size = size
      super()
    end

    def call
      return initials_tile unless @platform.logo_url

      tag.img(src: @platform.logo_url, alt: "", width: pixels, height: pixels, loading: "lazy",
              class: class_names("na-platform-logo", "na-platform-logo--small": small?))
    end

    private

    def initials_tile
      tag.span(initials, aria: { hidden: true },
                         class: class_names("na-platform-logo", "na-platform-logo--initials", "na-platform-logo--small": small?))
    end

    def pixels = SIZES.fetch(@size)

    def small? = @size == :small

    def initials
      words = @platform.name.split
      (words.one? ? words.first.first(2) : words.first(MAX_INITIALS).map(&:first).join).upcase
    end
  end
end
