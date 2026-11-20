class Users::SessionsController < Devise::SessionsController
  def create
    super do |user|
      merge_guest_taste_profile(user)
    end
  end

  private

  # The swipes made as a guest follow the visitor into the account they sign in to.
  def merge_guest_taste_profile(user)
    token = cookies.signed[CurrentTasteProfile::SESSION_COOKIE]
    TasteProfile.merge_session_profile(token, into: user)
    cookies.delete(CurrentTasteProfile::SESSION_COOKIE)
  end
end
