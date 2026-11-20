class StreamingAvailability < ApplicationRecord
  COUNTRY_CODE_FORMAT = /\A[A-Z]{2}\z/

  belongs_to :anime
  belongs_to :streaming_platform

  enum :offer_type, { flatrate: "flatrate", free: "free", ads: "ads" }, prefix: :offer, validate: true

  validates :country_code, presence: true, format: { with: COUNTRY_CODE_FORMAT }
  validates :offer_type, uniqueness: { scope: %i[anime_id streaming_platform_id country_code] }
end
