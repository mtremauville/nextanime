class WatchlistEntriesController < ApplicationController
  PROGRESS_MOVES = %w[advance rewind].freeze

  before_action :authenticate_user!
  after_action :verify_authorized, only: %i[create update destroy]
  after_action :verify_policy_scoped, only: %i[index update destroy]

  def index
    @overview = WatchlistOverview.new(policy_scope(WatchlistEntry))
    @status = status_filter
    @entries = @overview.listed(@status)
  end

  def create
    anime = Anime.find(params[:anime_id])
    entry = current_user.watchlist_entries.build(anime: anime)
    authorize entry
    put_in_list(entry)
    redirect_to anime_path(anime), notice: t(".added"), status: :see_other
  end

  def update
    entry = policy_scope(WatchlistEntry).find(params[:id])
    authorize entry
    entry.public_send(progress_move)
    redirect_to watchlist_path(status: status_filter), status: :see_other
  end

  def destroy
    entry = policy_scope(WatchlistEntry).find(params[:id])
    authorize entry
    entry.destroy!
    redirect_to watchlist_path(status: status_filter), status: :see_other
  end

  private

  def status_filter = params[:status].presence_in(WatchlistEntry.statuses.keys)

  def progress_move
    params.require(:move).presence_in(PROGRESS_MOVES) || raise(ActionController::BadRequest, "Unknown move")
  end

  # An anime already in the list, or added twice at once by a double click, keeps its
  # existing entry as it is, so that the progress made is never lost.
  def put_in_list(entry)
    entry.save!
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    current_user.watchlist_entries.find_by!(anime: entry.anime)
  end
end
