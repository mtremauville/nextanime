FactoryBot.define do
  factory :recommendation do
    taste_profile
    anime
    score { 0.87 }
  end
end
