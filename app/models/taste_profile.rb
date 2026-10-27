class TasteProfile < ApplicationRecord
  belongs_to :user, optional: true
  has_many :swipes, dependent: :destroy

  validates :user_id, uniqueness: true, allow_nil: true
  validates :session_token, uniqueness: true, allow_nil: true
  validate :owner_present

  private

  def owner_present
    return if user.present? || session_token.present?

    errors.add(:base, "A taste profile needs a user or a session token")
  end
end
