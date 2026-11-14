# What the "where to watch" block of the page of an anime shows for a country: the platforms that
# offer the anime there, the best offers first, each with the link to watch it.
class AnimeWhereToWatch
  Entry = Data.define(:platform, :offer_type, :url)

  OFFER_RANK = %w[flatrate free ads].each_with_index.to_h.freeze

  def initialize(anime:, country_code:)
    @anime = anime
    @country_code = country_code
  end

  # Without a match, an empty list does not mean that the anime is not available: it is not known.
  def known?
    @anime.tmdb_match.present? && @anime.tmdb_match.matched?
  end

  def entries
    ranked = availabilities.sort_by do |availability|
      [ OFFER_RANK.fetch(availability.offer_type), availability.streaming_platform.name ]
    end
    ranked.map { |availability| entry_for(availability) }
  end

  private

  def availabilities
    @anime.streaming_availabilities.where(country_code: @country_code).includes(:streaming_platform)
  end

  def entry_for(availability)
    platform = availability.streaming_platform
    Entry.new(platform: platform, offer_type: availability.offer_type, url: direct_links[platform.id] || watch_page)
  end

  # The link of AniList goes straight to the anime on the platform: it is preferred to the page of TMDB.
  def direct_links
    @direct_links ||= @anime.streaming_links.order(:id).group_by(&:streaming_platform_id).transform_values do |links|
      links.first.url
    end
  end

  def watch_page
    @anime.tmdb_match&.then { |match| match.watch_links[@country_code] }
  end
end
