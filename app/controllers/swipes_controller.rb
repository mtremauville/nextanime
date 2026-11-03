class SwipesController < ApplicationController
  include CurrentTasteProfile

  PROGRESS_TARGET = "deck-progress".freeze
  DECK_TARGET = "swipe-deck".freeze

  rescue_from ActiveRecord::RecordInvalid, ArgumentError, with: :unprocessable

  def index
    swiped_ids = swiped_anime_ids
    @animes = SwipeDeckQuery.new(excluding: swiped_ids).call
    @deck_finished = @animes.empty? && swiped_ids.any?
  end

  def create
    anime = Anime.find(swipe_params[:anime_id])
    current_taste_profile.record_swipe(anime, liked: liked_param)

    respond_to do |format|
      format.turbo_stream { render turbo_stream: deck_stream }
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

  def position_param
    swipe_params[:position].to_i
  end

  def total_param
    swipe_params[:total].to_i
  end

  # The position is the next card to show: one past the total means the deck is done.
  def deck_stream
    if position_param == total_param + 1
      turbo_stream.replace(DECK_TARGET, Molecules::DeckFinishedComponent.new(recommendations_href: recommendations_path))
    else
      turbo_stream.replace(PROGRESS_TARGET, Molecules::DeckProgressComponent.new(position: position_param, total: total_param))
    end
  end

  def unprocessable
    head :unprocessable_content
  end
end
