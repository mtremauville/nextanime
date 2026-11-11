class WatchlistEntriesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, only: :create
  after_action :verify_policy_scoped, only: :index

  def index
    @overview = WatchlistOverview.new(policy_scope(WatchlistEntry))
    @status = params[:status].presence_in(WatchlistEntry.statuses.keys)
    @entries = @overview.listed(@status)
  end

  def create
    anime = Anime.find(params[:anime_id])
    entry = current_user.watchlist_entries.build(anime: anime)
    authorize entry
    put_in_list(entry)
    redirect_to anime_path(anime), notice: t(".added"), status: :see_other
  end

  private

  # An anime already in the list, or added twice at once by a double click, keeps its
  # existing entry as it is, so that the progress made is never lost.
  def put_in_list(entry)
    entry.save!
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    current_user.watchlist_entries.find_by!(anime: entry.anime)
  end
end
