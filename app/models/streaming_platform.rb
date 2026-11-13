class StreamingPlatform < ApplicationRecord
  has_many :streaming_links, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
end
