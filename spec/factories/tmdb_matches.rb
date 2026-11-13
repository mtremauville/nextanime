FactoryBot.define do
  factory :tmdb_match do
    anime
    tmdb_id { 209_867 }
    media_type { :tv }
    checked_at { Time.current }

    trait :unmatched do
      tmdb_id { nil }
      media_type { nil }
    end
  end
end
