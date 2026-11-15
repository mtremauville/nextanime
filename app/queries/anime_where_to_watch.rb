# What the "where to watch" block of the page of an anime shows for a country: the platforms that
# offer the anime there, the best offers first, each with the link to watch it.
class AnimeWhereToWatch
  Entry = Data.define(:platform, :offer_types, :url)

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
    entries = offer_types_by_platform.map do |platform, offer_types|
      Entry.new(platform: platform, offer_types: offer_types, url: link_for(platform))
    end
    entries.sort_by { |entry| [ OFFER_RANK.fetch(entry.offer_types.first), entry.platform.name ] }
  end

  # TMDB gives no address on the platforms: its page lists the platforms and is credited as the source.
  def tmdb_page_url
    @anime.tmdb_match&.then { |match| match.watch_links[@country_code] }
  end

  private

  def offer_types_by_platform
    availabilities.group_by(&:streaming_platform).transform_values do |offers|
      offers.map(&:offer_type).sort_by { |offer_type| OFFER_RANK.fetch(offer_type) }
    end
  end

  def availabilities
    @anime.streaming_availabilities.where(country_code: @country_code).includes(:streaming_platform)
  end

  # The link of AniList goes straight to the anime on the platform: it is preferred to the search of
  # the title on the platform, which is preferred to the home page of the platform.
  def link_for(platform)
    direct_links[platform.id] || platform.search_url(search_title) || platform.homepage_url
  end

  # A search of the title of a later season finds nothing: the title of the series is searched.
  def search_title
    @search_title ||= Tmdb::TitleNormalizer.series_title(@anime.display_title)
  end

  def direct_links
    @direct_links ||= @anime.streaming_links.order(:id).group_by(&:streaming_platform_id).transform_values do |links|
      links.first.url
    end
  end
end
