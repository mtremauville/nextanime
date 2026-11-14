module Molecules
  # One platform where an anime can be watched: its logo, its name and the type of the offer. It is a
  # link to the anime on the platform when the address is known.
  class PlatformRowComponent < ViewComponent::Base
    # The addresses come from AniList and TMDB: only a web address is made a link.
    WEB_ADDRESS = %r{\Ahttps?://}i

    def initialize(platform:, offer_type:, url: nil)
      @platform = platform
      @offer_type = offer_type
      @url = url if url.to_s.match?(WEB_ADDRESS)
      super()
    end

    private

    attr_reader :platform, :offer_type, :url

    def tag_name = url ? :a : :div

    def row_attributes
      attributes = { class: "na-platform-row" }
      attributes.merge!(href: url, target: "_blank", rel: "noopener noreferrer") if url
      attributes
    end
  end
end
