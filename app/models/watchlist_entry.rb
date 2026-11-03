class WatchlistEntry < ApplicationRecord
  belongs_to :user
  belongs_to :anime

  enum :status, { plan_to_watch: 0, watching: 1, completed: 2 }, validate: true

  validates :anime_id, uniqueness: { scope: :user_id }
  validates :progress, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
