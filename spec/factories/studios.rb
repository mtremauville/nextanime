FactoryBot.define do
  factory :studio do
    sequence(:anilist_studio_id) { |number| number }
    sequence(:name) { |number| "Studio #{number}" }
  end
end
