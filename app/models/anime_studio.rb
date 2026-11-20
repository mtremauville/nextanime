class AnimeStudio < ApplicationRecord
  belongs_to :anime
  belongs_to :studio

  validates :studio_id, uniqueness: { scope: :anime_id }
  validates :main, uniqueness: { scope: :anime_id }, if: :main?
end
