class ProfilesController < ApplicationController
  before_action :authenticate_user!

  # Only ever reads the profile of the signed in account; a profile that was
  # never created is built in memory so the page can show zeros without writing.
  def show
    @taste_profile = current_user.taste_profile || current_user.build_taste_profile
    @swipes_count = @taste_profile.swipes.count
    @watchlist_count = current_user.watchlist_entries.count
  end
end
