class HomeController < ApplicationController
  def show
    return redirect_to(discover_path) if current_user

    @poster_urls = ShowcasePostersQuery.new.call
  end
end
