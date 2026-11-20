module Molecules
  # An anime that airs on a day of the calendar: its poster, its title, its next episode
  # and the time it airs at. It says so when the anime is in the watchlist of the member.
  class AiringItemComponent < ViewComponent::Base
    CLOCK_FORMAT = "%H:%M".freeze

    def initialize(anime:, in_watchlist: false)
      @anime = anime
      @in_watchlist = in_watchlist
      super()
    end

    private

    attr_reader :anime, :in_watchlist

    def css_class = class_names("na-airing", "na-airing--in-watchlist": in_watchlist)

    def watchlist_label = I18n.t("calendar.item.in_watchlist")

    def title = anime.display_title

    def episode_label = I18n.t("calendar.item.episode", number: anime.next_episode)

    def airing_time = anime.next_airing_at

    def clock = I18n.l(airing_time, format: CLOCK_FORMAT)
  end
end
