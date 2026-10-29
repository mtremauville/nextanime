# Builds the deck shown to a visitor: popular anime that differ from each other,
# so that a few swipes already say a lot about the taste.
class SwipeDeckQuery
  DEFAULT_SIZE = 24
  CANDIDATES_LIMIT = 200

  def initialize(size: DEFAULT_SIZE)
    @size = size
  end

  def call
    pool = candidates.to_a
    covered = Set.new

    Array.new([ size, pool.size ].min) do
      pick = pool.each_with_index.max_by { |anime, rank| [ novelty(anime, covered), -rank ] }.first
      pool.delete(pick)
      covered.merge(traits(pick))
      pick
    end
  end

  private

  attr_reader :size

  def candidates
    Anime.where.not(cover_image_url: nil)
         .includes(:genres)
         .order(Anime.arel_table[:popularity].desc.nulls_last)
         .limit(CANDIDATES_LIMIT)
  end

  def novelty(anime, covered)
    traits(anime).count { |trait| covered.exclude?(trait) }
  end

  def traits(anime)
    genres = anime.genres.map { |genre| [ :genre, genre.id ] }

    [ *genres, [ :format, anime.format ], [ :decade, decade(anime) ] ].reject { |_kind, value| value.nil? }
  end

  def decade(anime)
    year = anime.start_date&.year
    year && (year / 10) * 10
  end
end
