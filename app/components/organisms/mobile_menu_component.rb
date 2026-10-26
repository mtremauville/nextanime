class Organisms::MobileMenuComponent < ViewComponent::Base
  DOM_ID = "mobile-menu".freeze
  THEMES = { "dark" => "Sombre", "light" => "Clair" }.freeze

  attr_reader :items, :countries, :selected_country

  def initialize(items:, countries:, selected_country:)
    @items = items
    @countries = countries
    @selected_country = selected_country
  end
end
