# The country whose streaming offers are shown: the one that a member keeps in their account, else
# the one that a visitor keeps in a cookie, else France.
module CurrentCountry
  extend ActiveSupport::Concern

  COOKIE_NAME = :country
  COOKIE_DURATION = 1.day

  included do
    helper_method :current_country_code
  end

  private

  def current_country_code
    chosen = current_user&.country || cookies[COOKIE_NAME]
    Country.supported?(chosen) ? chosen : Country::DEFAULT
  end
end
