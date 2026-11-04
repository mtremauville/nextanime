# Keeps the deck of a swipe session in the visitor's session, so that a reload
# resumes the same cards instead of drawing new ones. A session is over once
# every card has been swiped: the next visit then draws a new one.
class SwipeSession
  STORE_KEY = :swipe_deck_ids

  def initialize(store, swiped_anime_ids:, size: SwipeDeckQuery::DEFAULT_SIZE)
    @store = store
    @swiped_anime_ids = swiped_anime_ids.to_a
    @size = size
  end

  # The cards still to swipe, in the order they were drawn.
  def animes
    @animes ||= resumed_animes || drawn_animes
  end

  def total
    animes # draws the session when there is none yet
    store[STORE_KEY].size
  end

  def completed
    total - animes.size
  end

  private

  attr_reader :store, :swiped_anime_ids, :size

  # A card that vanished from the catalog makes the session unusable: its
  # progress could never reach 100 %, so a new one is drawn instead.
  def resumed_animes
    remaining_ids = Array(store[STORE_KEY]) - swiped_anime_ids
    return if remaining_ids.empty?

    animes_by_id = Anime.where(id: remaining_ids).includes(:genres, :main_studio).index_by(&:id)
    cards = animes_by_id.values_at(*remaining_ids).compact
    cards if cards.size == remaining_ids.size
  end

  def drawn_animes
    SwipeDeckQuery.new(size: size, excluding: swiped_anime_ids).call.tap do |cards|
      store[STORE_KEY] = cards.map(&:id)
    end
  end
end
