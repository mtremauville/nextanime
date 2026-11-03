# The short labels that describe an anime on a card: what it is, who made it,
# how long it runs and what it is about.
class AnimeSummary
  MAX_GENRES = 3
  SEPARATOR = " · ".freeze

  def initialize(anime)
    @anime = anime
  end

  def badge = joined([ format_label, anime.start_date&.year ])

  def meta = joined([ studio_name, episodes_label ])

  def line = joined([ badge, studio_name ])

  def genre_labels = anime.genres.first(MAX_GENRES).map(&:name)

  private

  attr_reader :anime

  def studio_name = anime.main_studio&.name

  def format_label
    I18n.t("animes.formats.#{anime.format}") if anime.format
  end

  def episodes_label
    I18n.t("animes.episodes", count: anime.episodes) if anime.episodes
  end

  def joined(parts) = parts.compact.join(SEPARATOR).presence
end
