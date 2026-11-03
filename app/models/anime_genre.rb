class AnimeGenre < ApplicationRecord
  belongs_to :anime
  belongs_to :genre

  validates :genre_id, uniqueness: { scope: :anime_id }
end
