class SwipesController < ApplicationController
  include CurrentTasteProfile

  PROGRESS_TARGET = "deck-progress".freeze

  rescue_from ActiveRecord::RecordInvalid, ArgumentError, with: :unprocessable

  def index
    @animes = SwipeDeckQuery.new.call
  end

  def create
    anime = Anime.find(swipe_params[:anime_id])
    current_taste_profile.record_swipe(anime, liked: liked_param)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: progress_stream }
      format.any { head :created }
    end
  end

  private

  def swipe_params
    params.permit(:anime_id, :liked, :position, :total)
  end

  def liked_param
    ActiveModel::Type::Boolean.new.cast(swipe_params[:liked])
  end

  def progress_stream
    progress = Molecules::DeckProgressComponent.new(
      position: swipe_params[:position].to_i,
      total: swipe_params[:total].to_i
    )
    turbo_stream.replace(PROGRESS_TARGET, progress)
  end

  def unprocessable
    head :unprocessable_content
  end
end
