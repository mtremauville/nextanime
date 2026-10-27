FactoryBot.define do
  factory :swipe do
    taste_profile
    anime
    liked { true }

    trait :passed do
      liked { false }
    end
  end
end
