class TasteProfile < ApplicationRecord
  belongs_to :user, optional: true
  has_many :swipes, dependent: :destroy
  has_many :recommendations, dependent: :destroy

  validates :user_id, uniqueness: true, allow_nil: true
  validates :session_token, uniqueness: true, allow_nil: true
  validate :owner_present

  def self.for_session(token)
    find_or_create_by!(session_token: token)
  end

  def record_swipe(anime, liked:)
    swipe = swipes.find_or_initialize_by(anime: anime)
    swipe.update!(liked: liked)
    swipe
  end

  private

  def owner_present
    return if user.present? || session_token.present?

    errors.add(:base, "A taste profile needs a user or a session token")
  end
end
