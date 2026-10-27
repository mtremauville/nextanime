class Organisms::MainNavigationComponent < ViewComponent::Base
  BRAND = "NextAnime".freeze
  DEFAULT_COUNTRY = "FR".freeze
  COUNTRIES = {
    "FR" => "France",
    "BE" => "Belgique",
    "CH" => "Suisse",
    "CA" => "Canada",
    "US" => "États-Unis",
    "GB" => "Royaume-Uni"
  }.freeze

  def initialize(current_path:, user: nil)
    @current_path = current_path
    @user = user
  end

  private

  attr_reader :user

  def nav_items
    items.map { |item| item.merge(current: current?(item[:href])) }
  end

  def items
    [
      { label: "Découvrir", href: root_path, icon: "stars" },
      { label: "Catalogue", href: catalogue_path, icon: "grid" },
      { label: "Recos", href: recommendations_path, icon: "heart" },
      ({ label: "Watchlist", href: watchlist_path, icon: "bookmark" } if user),
      { label: "Calendrier", href: calendar_path, icon: "calendar3" }
    ].compact
  end

  def country_options
    options_for_select(COUNTRIES.map { |code, name| [ name, code ] }, DEFAULT_COUNTRY)
  end

  def current?(href)
    return @current_path == href if href == root_path

    @current_path == href || @current_path.start_with?("#{href}/")
  end
end
