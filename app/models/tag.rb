class Tag < ApplicationRecord
  validates :anilist_tag_id, presence: true, uniqueness: true
  validates :name, presence: true

  scope :not_adult, -> { where(adult: false) }
end
