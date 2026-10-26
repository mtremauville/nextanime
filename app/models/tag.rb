class Tag < ApplicationRecord
  has_many :anime_tags, dependent: :destroy
  has_many :animes, through: :anime_tags

  validates :anilist_tag_id, presence: true, uniqueness: true
  validates :name, presence: true

  scope :not_adult, -> { where(adult: false) }
end
