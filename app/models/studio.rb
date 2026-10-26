class Studio < ApplicationRecord
  validates :anilist_studio_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
end
