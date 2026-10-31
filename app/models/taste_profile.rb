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

  # Turns the profile of a visitor into the profile of the account it just created.
  def self.attach_session_profile(token, to:)
    return if token.blank? || to.taste_profile

    profile = find_by(session_token: token, user_id: nil)
    profile&.tap { |found| found.update!(user: to, session_token: nil) }
  end

  def record_swipe(anime, liked:)
    swipe = swipes.find_or_initialize_by(anime: anime)
    swipe.update!(liked: liked)
    swipe
  end

  def swiped_anime_ids
    swipes.pluck(:anime_id)
  end

  private

  def owner_present
    return if user.present? || session_token.present?

    errors.add(:base, "A taste profile needs a user or a session token")
  end
end
