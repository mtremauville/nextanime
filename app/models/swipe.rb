class Swipe < ApplicationRecord
  belongs_to :taste_profile
  belongs_to :anime

  validates :anime_id, uniqueness: { scope: :taste_profile_id }
  validates :liked, inclusion: { in: [ true, false ] }
end
