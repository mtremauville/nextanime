class Recommendation < ApplicationRecord
  belongs_to :taste_profile
  belongs_to :anime

  validates :anime_id, uniqueness: { scope: :taste_profile_id }
  validates :score, presence: true,
                    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
