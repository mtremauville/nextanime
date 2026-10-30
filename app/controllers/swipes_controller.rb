class SwipesController < ApplicationController
  include CurrentTasteProfile

  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable

  def index
    @animes = SwipeDeckQuery.new.call
  end

  def create
    anime = Anime.find(swipe_params[:anime_id])
    current_taste_profile.record_swipe(anime, liked: liked_param)
    head :created
  end

  private

  def swipe_params
    params.permit(:anime_id, :liked)
  end

  def liked_param
    ActiveModel::Type::Boolean.new.cast(swipe_params[:liked])
  end

  def unprocessable
    head :unprocessable_content
  end
end
