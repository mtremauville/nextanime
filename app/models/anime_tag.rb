class AnimeTag < ApplicationRecord
  MIN_RANK = 0
  MAX_RANK = 100

  belongs_to :anime
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :anime_id }
  validates :rank, numericality: {
    only_integer: true,
    greater_than_or_equal_to: MIN_RANK,
    less_than_or_equal_to: MAX_RANK
  }
end
