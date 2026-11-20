class Organisms::MobileMenuComponent < ViewComponent::Base
  DOM_ID = "mobile-menu".freeze
  THEMES = { "dark" => "Sombre", "light" => "Clair" }.freeze

  attr_reader :items, :countries, :selected_country, :user

  def initialize(items:, countries:, selected_country:, user: nil)
    @items = items
    @countries = countries
    @selected_country = selected_country
    @user = user
  end
end
