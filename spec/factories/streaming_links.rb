FactoryBot.define do
  factory :streaming_link do
    anime
    streaming_platform
    sequence(:url) { |number| "https://streaming.example/watch/#{number}" }
    language { nil }
  end
end
