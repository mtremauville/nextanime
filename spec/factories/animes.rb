FactoryBot.define do
  factory :anime do
    sequence(:anilist_id) { |number| number }
    sequence(:title_romaji) { |number| "Anime #{number}" }
    format { :tv }
    airing_status { :finished }
    episodes { 12 }
  end
end
