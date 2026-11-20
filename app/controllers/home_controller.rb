class HomeController < ApplicationController
  def show
    return redirect_to(discover_path) if current_user

    @poster_urls = LandingPostersQuery.new.call
  end
end
