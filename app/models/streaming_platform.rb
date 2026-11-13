class StreamingPlatform < ApplicationRecord
  has_many :streaming_links, dependent: :destroy
  has_many :streaming_availabilities, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :tmdb_provider_id, uniqueness: true, allow_nil: true
end
