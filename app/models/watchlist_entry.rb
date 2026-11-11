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
    return unless total_episodes.to_i.positive?

    [ (progress * FULL_PERCENT.to_f / total_episodes).round, FULL_PERCENT ].min
  end
end
