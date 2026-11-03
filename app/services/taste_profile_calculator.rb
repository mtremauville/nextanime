# Turns the swipes of a taste profile into one affinity per genre and per tag.
# An affinity goes from -1 (always passed) to 1 (always liked); a few swipes count for little.
class TasteProfileCalculator
  SMOOTHING = 2
  PRECISION = 4
  MAX_RANK = AnimeTag::MAX_RANK.to_f

  # Adds up swipes per name: the balance of likes against passes, and how much was swiped in all.
  class Tally
    def initialize
      @balances = Hash.new(0.0)
      @totals = Hash.new(0.0)
    end

    def add(name, amount)
      @balances[name] += amount
      @totals[name] += amount.abs
    end

    def affinities
      @balances.to_h { |name, balance| [ name, (balance / (@totals[name] + SMOOTHING)).round(PRECISION) ] }
    end
  end

  def initialize(taste_profile)
    @taste_profile = taste_profile
  end

  def call
    genres = Tally.new
    tags = Tally.new

    swipes.each do |swipe|
      direction = swipe.liked ? 1 : -1
      swipe.anime.genres.each { |genre| genres.add(genre.name, direction) }
      swipe.anime.anime_tags.each { |anime_tag| tags.add(anime_tag.tag.name, direction * anime_tag.rank / MAX_RANK) }
    end

    { genre_weights: genres.affinities, tag_weights: tags.affinities }
  end

  private

  attr_reader :taste_profile

  def swipes
    taste_profile.swipes.includes(anime: [ :genres, { anime_tags: :tag } ])
  end
end
