module Molecules
  # An anime that airs on a day of the calendar: its poster, its title, its next episode
  # and the time it airs at.
  class AiringItemComponent < ViewComponent::Base
    CLOCK_FORMAT = "%H:%M".freeze

    def initialize(anime:)
      @anime = anime
      super()
    end

    private

    attr_reader :anime

    def title = anime.display_title

    def episode_label = I18n.t("calendar.item.episode", number: anime.next_episode)

    def airing_time = anime.next_airing_at

    def clock = I18n.l(airing_time, format: CLOCK_FORMAT)
  end
end
