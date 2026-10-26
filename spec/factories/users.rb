FactoryBot.define do
  factory :user do
    sequence(:email) { |number| "user#{number}@example.com" }
    password { "correct horse battery staple" }
    password_confirmation { password }
  end
end
