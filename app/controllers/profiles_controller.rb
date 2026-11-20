class ProfilesController < ApplicationController
  before_action :authenticate_user!

  # Only ever reads the profile of the signed in account; a profile that was
  # never created is built in memory so the page can show zeros without writing.
  def show
    @account = current_user
    load_profile
  end

  # The current password is always required, and a blank new password keeps the old one.
  # A copy of the account takes the changes, so a refused update never alters what the page shows.
  def update
    @account = User.find(current_user.id)

    if @account.update_with_password(account_params)
      bypass_sign_in(@account)
      redirect_to profile_path, notice: t(".notice")
    else
      load_profile
      render :show, status: :unprocessable_content
    end
  end

  private

  def load_profile
    @taste_profile = current_user.taste_profile || current_user.build_taste_profile
    @swipes_count = @taste_profile.swipes.count
    @watchlist_count = current_user.watchlist_entries.count
  end

  def account_params
    params.expect(user: %i[email password current_password])
  end
end
