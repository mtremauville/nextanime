FactoryBot.define do
  factory :genre do
    sequence(:name) { |number| "Genre #{number}" }
  end
end
