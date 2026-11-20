class TmdbMatch < ApplicationRecord
  belongs_to :anime

  enum :media_type, { tv: "tv", movie: "movie" }, prefix: :media, validate: { allow_nil: true }

  scope :matched, -> { where.not(tmdb_id: nil) }
  scope :unmatched, -> { where(tmdb_id: nil) }

  validates :anime_id, uniqueness: true
  validates :checked_at, presence: true
  validates :media_type, presence: true, if: :tmdb_id?
  validates :tmdb_id, presence: true, if: :media_type?

  def matched?
    tmdb_id.present?
  end
end
