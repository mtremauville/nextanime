class Organisms::MainNavigationComponent < ViewComponent::Base
  def initialize(current_path:, user: nil, selected_country: Country::DEFAULT)
    @current_path = current_path
    @user = user
    @selected_country = selected_country
  end

  private

  attr_reader :user, :selected_country

  def nav_items
    items.map { |item| item.merge(current: current?(item[:href])) }
  end

  def items
    user ? public_items + member_items : public_items
  end

  def public_items
    [
      { label: "Découvrir", href: discover_path, icon: "stars" },
      { label: "Catalogue", href: catalogue_path, icon: "grid" }
    ]
  end

  def member_items
    [
      { label: "Recos", href: recommendations_path, icon: "heart" },
      { label: "Watchlist", href: watchlist_path, icon: "bookmark" },
      { label: "Calendrier", href: calendar_path, icon: "calendar3" }
    ]
  end

  def country_options
    options_for_select(Country::NAMES.map { |code, name| [ name, code ] }, selected_country)
  end

  def current?(href)
    @current_path == href || @current_path.start_with?("#{href}/")
  end
end
