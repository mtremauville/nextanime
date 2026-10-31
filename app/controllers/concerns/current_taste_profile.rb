# Identifies a visitor without an account by a signed cookie, and finds the
# taste profile attached to it.
module CurrentTasteProfile
  extend ActiveSupport::Concern

  SESSION_COOKIE = :taste_session
  SESSION_DURATION = 1.year

  private

  # Creates the profile when the visitor has none yet: use it when a swipe is recorded.
  def current_taste_profile
    @current_taste_profile ||= TasteProfile.for_session(taste_session_token)
  end

  # Looking at the deck must not create anything, so this only reads.
  def swiped_anime_ids
    existing_taste_profile&.swiped_anime_ids || []
  end

  def existing_taste_profile
    token = cookies.signed[SESSION_COOKIE]
    TasteProfile.find_by(session_token: token) if token
  end

  def taste_session_token
    cookies.signed[SESSION_COOKIE] || start_taste_session
  end

  def start_taste_session
    token = SecureRandom.urlsafe_base64(32)
    cookies.signed[SESSION_COOKIE] = {
      value: token,
      expires: SESSION_DURATION.from_now,
      httponly: true,
      same_site: :lax,
      secure: request.ssl?
    }
    token
  end
end
