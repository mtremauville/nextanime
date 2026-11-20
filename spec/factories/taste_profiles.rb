FactoryBot.define do
  factory :taste_profile do
    sequence(:session_token) { |number| "session-token-#{number}" }

    trait :with_user do
      user
      session_token { nil }
    end
  end
end
