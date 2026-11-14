module Atoms
  # The logo of a streaming platform, or its initials when TMDB gave none. The name of the platform
  # is always written next to it, so the logo is decorative.
  class PlatformLogoComponent < ViewComponent::Base
    SIZE = 44
    MAX_INITIALS = 3

    def initialize(platform:)
      @platform = platform
      super()
    end

    def call
      return initials_tile unless @platform.logo_url

      tag.img(src: @platform.logo_url, alt: "", width: SIZE, height: SIZE, loading: "lazy", class: "na-platform-logo")
    end

    private

    def initials_tile
      tag.span(initials, class: "na-platform-logo na-platform-logo--initials", aria: { hidden: true })
    end

    def initials
      words = @platform.name.split
      (words.one? ? words.first.first(2) : words.first(MAX_INITIALS).map(&:first).join).upcase
    end
  end
end
