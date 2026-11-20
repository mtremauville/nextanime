# Says in one sentence why an anime fits a taste profile: the tags, then the genres,
# that the profile loves and the anime carries. Nothing is said when there is nothing in common.
class MatchExplainer
  LIMIT = 3
  JOINERS = { words_connector: ", ", two_words_connector: " et ", last_word_connector: " et " }.freeze

  def initialize(taste_profile)
    @genre_weights = taste_profile.genre_weights
    @tag_weights = taste_profile.tag_weights
  end

  def call(anime)
    names = (loved_tags(anime) + loved_genres(anime)).first(LIMIT)
    return if names.empty?

    I18n.t("match_explanation.sentence", names: names.to_sentence(**JOINERS))
  end

  private

  attr_reader :genre_weights, :tag_weights

  def loved_tags(anime) = loved(anime.anime_tags.map { |anime_tag| anime_tag.tag.name }, tag_weights)

  def loved_genres(anime) = loved(anime.genres.map(&:name), genre_weights)

  # Only what the profile likes counts, the most loved first.
  def loved(names, weights)
    names.select { |name| weights.fetch(name, 0.0).positive? }.sort_by { |name| -weights.fetch(name) }
  end
end
