FactoryBot.define do
  factory :tag do
    sequence(:anilist_tag_id) { |number| number }
    sequence(:name) { |number| "Tag #{number}" }
    category { "Theme-Other" }
    adult { false }
  end
end
