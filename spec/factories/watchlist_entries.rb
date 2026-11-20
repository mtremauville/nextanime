FactoryBot.define do
  factory :watchlist_entry do
    user
    anime
    status { :plan_to_watch }
    progress { 0 }

    trait :watching do
      status { :watching }
      progress { 3 }
    end

    trait :completed do
      status { :completed }
      progress { 12 }
    end
  end
end
