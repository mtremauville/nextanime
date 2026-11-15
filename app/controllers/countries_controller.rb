class CountriesController < ApplicationController
  def update
    remember(params[:country]) if Country.supported?(params[:country])

    redirect_back_or_to root_path, status: :see_other
  end

  private

  # A member keeps the choice in their account, a visitor in a cookie.
  def remember(country_code)
    if current_user
      current_user.update!(country: country_code)
    else
      cookies.permanent[:country] = { value: country_code, httponly: true, same_site: :lax }
    end
  end
end
