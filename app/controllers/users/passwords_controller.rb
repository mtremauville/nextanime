class Users::PasswordsController < Devise::PasswordsController
  before_action :require_password_reset_enabled

  private

  # Nothing is sent while the reset is off, so there is nothing to offer: the pages are simply not there.
  def require_password_reset_enabled
    head :not_found unless password_reset_enabled?
  end
end
