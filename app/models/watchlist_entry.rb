class WatchlistEntry < ApplicationRecord
  FULL_PERCENT = 100

  belongs_to :user
  belongs_to :anime

  enum :status, { plan_to_watch: 0, watching: 1, completed: 2 }, validate: true

  validates :anime_id, uniqueness: { scope: :user_id }
  validates :progress, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def total_episodes = anime.episodes

  # Nil while the number of episodes is unknown (an anime still airing).
  def percent
    return unless known_total?

    [ (progress * FULL_PERCENT.to_f / total_episodes).round, FULL_PERCENT ].min
  end

  def fully_watched? = known_total? && progress >= total_episodes

  def advance = move_to(progress + 1)

  def rewind = move_to(progress - 1)

  private

  def known_total? = total_episodes.to_i.positive?

  # The progress stays between zero and the last episode, and the status follows it.
  def move_to(episode)
    watched = [ episode, 0 ].max
    watched = [ watched, total_episodes ].min if known_total?
    update!(progress: watched, status: status_for(watched))
  end

  def status_for(watched)
    return "plan_to_watch" if watched.zero?
    return "completed" if known_total? && watched >= total_episodes

    "watching"
  end
end
