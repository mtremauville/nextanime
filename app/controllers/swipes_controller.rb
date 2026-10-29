class SwipesController < ApplicationController
  def index
    @animes = SwipeDeckQuery.new.call
  end
end
