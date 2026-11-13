FactoryBot.define do
  factory :streaming_availability do
    anime
    streaming_platform
    country_code { "FR" }
    offer_type { :flatrate }
  end
end
