class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :lockable
    has_one :taste_profile, dependent: :destroy
  validates :privacy_policy, acceptance: { allow_nil: false }, on: :create
end
