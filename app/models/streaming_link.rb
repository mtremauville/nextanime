class StreamingLink < ApplicationRecord
  belongs_to :anime
  belongs_to :streaming_platform

  validates :url, presence: true, uniqueness: { scope: :anime_id }
end
