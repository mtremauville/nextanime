class HomeController < ApplicationController
  def show
    redirect_to discover_path if current_user
  end
end
