FactoryBot.define do
  factory :streaming_platform do
    sequence(:name) { |number| "Platform #{number}" }
    sequence(:slug) { |number| "platform-#{number}" }
  end
end
