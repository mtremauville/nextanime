# The streaming platforms that offer each anime of a page of cards in a country, found in two queries
# for the whole page. The best offer comes first, then the platforms by name.
class PlatformsByAnime
  NO_PLATFORM = [].freeze

  def initialize(animes:, country_code:)
    @animes = animes
    @country_code = country_code
  end

  # Maps the id of each anime to its platforms. An anime without any known offer maps to an empty
  # list: it is not known to be available, which is not the same as being unavailable.
  def call
    platforms = availabilities.group_by(&:anime_id).transform_values { |offers| platforms_of(offers) }
    platforms.default = NO_PLATFORM
    platforms
  end

  private

  def availabilities
    StreamingAvailability.where(anime_id: @animes.map(&:id), country_code: @country_code).includes(:streaming_platform)
  end

  def platforms_of(offers)
    best_first = offers.sort_by do |offer|
      [ AnimeWhereToWatch::OFFER_RANK.fetch(offer.offer_type), offer.streaming_platform.name ]
    end
    best_first.map(&:streaming_platform).uniq
  end
end
