class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :lockable
    has_one :taste_profile, dependent: :destroy
    has_many :watchlist_entries, dependent: :destroy
    has_many :animes, through: :watchlist_entries
  validates :privacy_policy, acceptance: { allow_nil: false }, on: :create
end
