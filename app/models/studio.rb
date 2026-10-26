class Studio < ApplicationRecord
  has_many :anime_studios, dependent: :destroy
  has_many :animes, through: :anime_studios

  validates :anilist_studio_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
end
