module Tmdb
  # Stores where an anime can be watched, country by country, from the offers of TMDB.
  class AvailabilityImporter
    COUNTRIES = %w[FR BE CH CA US GB].freeze
    OFFER_TYPES = %w[flatrate free ads].freeze

    def initialize(client:, linker: AnimeLinker.new(client: client))
      @client = client
      @linker = linker
    end

    def import(anime)
      match = @linker.link(anime)
      return match unless match.matched?

      providers = @client.watch_providers(media_type: match.media_type, tmdb_id: match.tmdb_id)
      replace_availabilities(anime, providers)
      match
    end

    private

    def replace_availabilities(anime, providers_by_country)
      ApplicationRecord.transaction do
        anime.streaming_availabilities.destroy_all

        offers_in(providers_by_country).each do |offer|
          anime.streaming_availabilities.find_or_create_by!(
            streaming_platform: platform_for(offer[:provider]),
            country_code: offer[:country_code],
            offer_type: offer[:offer_type]
          )
        end
      end
    end

    # Rent and purchase offers are left out: they do not fit watching an anime week after week.
    def offers_in(providers_by_country)
      COUNTRIES.flat_map do |country_code|
        offers = providers_by_country.fetch(country_code, {})

        OFFER_TYPES.flat_map do |offer_type|
          offers.fetch(offer_type, []).map do |provider|
            { provider: provider, country_code: country_code, offer_type: offer_type }
          end
        end
      end
    end

    # A platform is found by its slug, so the one imported from AniList is reused and the
    # variants of a platform end up on the same record. Only the main provider gives its id.
    def platform_for(provider)
      name = provider.fetch("provider_name")
      base_name = ProviderNames.base_name(name)
      platform = StreamingPlatform.find_or_create_by!(slug: ProviderNames.slug(name)) do |new_platform|
        new_platform.name = base_name
      end

      platform.update!(tmdb_provider_id: provider.fetch("provider_id")) if name == base_name && platform.tmdb_provider_id.nil?
      platform
    end
  end
end
