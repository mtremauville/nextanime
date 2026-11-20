class CalendarController < ApplicationController
  before_action :authenticate_user!

  def show
    @calendar = AiringCalendar.new
    @watched_anime_ids = watched_anime_ids
  end

  private

  def watched_anime_ids
    current_user.watchlist_entries.pluck(:anime_id).to_set
  end
end
