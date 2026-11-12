class CalendarController < ApplicationController
  def show
    @calendar = AiringCalendar.new
    @watched_anime_ids = watched_anime_ids
  end

  private

  # The anime of the watchlist of the member; nothing for a visitor.
  def watched_anime_ids
    return Set.new unless user_signed_in?

    current_user.watchlist_entries.pluck(:anime_id).to_set
  end
end
