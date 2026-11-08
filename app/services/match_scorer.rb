# Tells how close an anime is to a taste profile, from 0 (everything the profile
# rejects) to 1 (everything it loves), 0.5 being neutral.
# The genres and the tags of the anime are compared with the affinities of the profile;
# the tags weigh more because they tell two anime of the same genre apart.
class MatchScorer
  GENRE_SHARE = 0.4
  TAG_SHARE = 0.6
  PRECISION = 4

  def initialize(taste_profile)
    @genre_weights = taste_profile.genre_weights
    @tag_weights = taste_profile.tag_weights
  end

  def call(anime)
    score(anime.genres.map(&:name), anime.anime_tags.map { |anime_tag| [ anime_tag.rank, anime_tag.tag.name ] })
  end

  def percentage(anime) = (call(anime) * 100).round

  # Scores many anime at once, by id. It reads the rows of the join tables and builds
  # no model, which is what makes it fast for a whole catalogue.
  def scores(anime_ids)
    return {} if anime_ids.empty?

    genre_names = genre_names_by_anime(anime_ids)
    ranked_tags = ranked_tags_by_anime(anime_ids)
    anime_ids.to_h { |id| [ id, score(genre_names.fetch(id, []), ranked_tags.fetch(id, [])) ] }
  end

  private

  attr_reader :genre_weights, :tag_weights

  # The genres are their names, the tags are pairs of rank and name.
  def score(genre_names, ranked_tags)
    affinity = blend(genre_affinity(genre_names), tag_affinity(ranked_tags))
    ((affinity + 1) / 2).round(PRECISION)
  end

  def genre_names_by_anime(anime_ids)
    rows = AnimeGenre.where(anime_id: anime_ids).joins(:genre).pluck(:anime_id, "genres.name")
    rows.group_by(&:first).transform_values { |group| group.map(&:last) }
  end

  def ranked_tags_by_anime(anime_ids)
    rows = AnimeTag.where(anime_id: anime_ids).joins(:tag).pluck(:anime_id, :rank, "tags.name")
    rows.group_by(&:first).transform_values { |group| group.map { |_, rank, name| [ rank, name ] } }
  end

  # An affinity goes from -1 to 1. A side the anime has nothing on does not weigh in.
  def blend(genre_affinity, tag_affinity)
    return 0.0 if genre_affinity.nil? && tag_affinity.nil?
    return tag_affinity if genre_affinity.nil?
    return genre_affinity if tag_affinity.nil?

    (GENRE_SHARE * genre_affinity) + (TAG_SHARE * tag_affinity)
  end

  def genre_affinity(names)
    return if names.empty?

    names.sum { |name| genre_weights.fetch(name, 0.0) } / names.size
  end

  # The higher a tag ranks for the anime, the more it counts.
  def tag_affinity(ranked_tags)
    total_rank = ranked_tags.sum(&:first)
    return if total_rank.zero?

    ranked_tags.sum { |rank, name| rank * tag_weights.fetch(name, 0.0) } / total_rank
  end
end
