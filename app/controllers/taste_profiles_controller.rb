class TasteProfilesController < ApplicationController
  before_action :authenticate_user!

  # Only ever touches the profile of the signed in account, never one picked by an id.
  def reset
    current_user.taste_profile&.reset!
    redirect_to profile_path, notice: t(".notice")
  end
end
