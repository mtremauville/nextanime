class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      attach_guest_taste_profile(user) if user.persisted?
    end
  end

  private

  # The swipes made as a guest follow the visitor into the new account.
  def attach_guest_taste_profile(user)
    token = cookies.signed[CurrentTasteProfile::SESSION_COOKIE]
    TasteProfile.attach_session_profile(token, to: user)
    cookies.delete(CurrentTasteProfile::SESSION_COOKIE)
  end
end
