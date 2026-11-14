module Molecules
  # One platform where an anime can be watched: its logo, its name and the types of its offers. It is
  # a link to the anime on the platform, or to the platform, when the address is known.
  class PlatformRowComponent < ViewComponent::Base
    # The addresses come from AniList and the list of platforms: only a web address is made a link.
    WEB_ADDRESS = %r{\Ahttps?://}i
    OFFER_SEPARATOR = " · ".freeze

    def initialize(platform:, offer_types:, url: nil)
      @platform = platform
      @offer_types = offer_types
      @url = url if url.to_s.match?(WEB_ADDRESS)
      super()
    end

    private

    attr_reader :platform, :offer_types, :url

    def tag_name = url ? :a : :div

    def offers_text
      offer_types.map { |offer_type| t("anime_page.where_to_watch.offers.#{offer_type}") }.join(OFFER_SEPARATOR)
    end

    def row_attributes
      attributes = { class: "na-platform-row" }
      attributes.merge!(href: url, target: "_blank", rel: "noopener noreferrer") if url
      attributes
    end
  end
end
