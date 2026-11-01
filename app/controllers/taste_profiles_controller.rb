class TasteProfilesController < ApplicationController
  include CurrentTasteProfile

  # Only ever touches the profile the visitor already owns, never one picked by an id.
  def reset
    existing_taste_profile&.reset!
    redirect_to root_path, notice: t(".notice")
  end
end
