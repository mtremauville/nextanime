# Everything the page of an anime shows, ready to display: the labels of its header,
# its tags ranked by relevance and the lines of its information card.
class AnimeDetails
  MAX_TAGS = 8
  INFORMATION_KEYS = %i[format episodes studio season status score].freeze

  RankedTag = Data.define(:name, :rank)

  def initialize(anime)
    @anime = anime
    @summary = AnimeSummary.new(anime)
  end

  def eyebrow = joined([ summary.badge, status_label ], AnimeSummary::SEPARATOR)

  def meta = summary.meta

  def genre_labels = anime.genres.map(&:name)

  def season_label = joined([ season_name, anime.season_year ], " ")

  def status_label
    I18n.t("animes.statuses.#{anime.airing_status}") if anime.airing_status
  end

  def score_label
    I18n.t("animes.score", score: anime.average_score) if anime.average_score
  end

  def tags
    ranked = anime.anime_tags.sort_by { |anime_tag| -anime_tag.rank }
    ranked.first(MAX_TAGS).map { |anime_tag| RankedTag.new(name: anime_tag.tag.name, rank: anime_tag.rank) }
  end

  def synopsis = anime.description.presence

  # Label and value pairs, in display order, without what is unknown.
  def information
    values = [ format_label, anime.episodes&.to_s, anime.main_studio&.name, season_label, status_label, score_label ]

    INFORMATION_KEYS.zip(values).filter_map do |key, value|
      [ I18n.t("animes.information.#{key}"), value ] if value.present?
    end
  end

  private

  attr_reader :anime, :summary

  def format_label
    I18n.t("animes.formats.#{anime.format}") if anime.format
  end

  def season_name
    I18n.t("animes.seasons.#{anime.season}") if anime.season
  end

  def joined(parts, separator) = parts.compact.join(separator).presence
end
