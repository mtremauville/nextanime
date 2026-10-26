class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :lockable

  validates :privacy_policy, acceptance: { allow_nil: false }, on: :create
end
