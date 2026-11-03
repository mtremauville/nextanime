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
    affinity = blend(genre_affinity(anime), tag_affinity(anime))
    ((affinity + 1) / 2).round(PRECISION)
  end

  def percentage(anime) = (call(anime) * 100).round

  private

  attr_reader :genre_weights, :tag_weights

  # An affinity goes from -1 to 1. A side the anime has nothing on does not weigh in.
  def blend(genre_affinity, tag_affinity)
    return 0.0 if genre_affinity.nil? && tag_affinity.nil?
    return tag_affinity if genre_affinity.nil?
    return genre_affinity if tag_affinity.nil?

    (GENRE_SHARE * genre_affinity) + (TAG_SHARE * tag_affinity)
  end

  def genre_affinity(anime)
    genres = anime.genres
    return if genres.empty?

    genres.sum { |genre| genre_weights.fetch(genre.name, 0.0) } / genres.size
  end

  # The higher a tag ranks for the anime, the more it counts.
  def tag_affinity(anime)
    anime_tags = anime.anime_tags
    total_rank = anime_tags.sum(&:rank)
    return if total_rank.zero?

    anime_tags.sum { |anime_tag| anime_tag.rank * tag_weights.fetch(anime_tag.tag.name, 0.0) } / total_rank
  end
end
