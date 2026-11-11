class WatchlistEntriesController < ApplicationController
  before_action :authenticate_user!, only: :create
  after_action :verify_authorized, only: :create

  def index
  end

  # An anime already in the list is left as it is, so that the progress made is never lost.
  def create
    anime = Anime.find(params[:anime_id])
    entry = current_user.watchlist_entries.find_or_initialize_by(anime: anime)
    authorize entry
    entry.save!
    redirect_to anime_path(anime), notice: t(".added"), status: :see_other
  end
end
