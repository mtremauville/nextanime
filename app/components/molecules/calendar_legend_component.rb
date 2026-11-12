module Molecules
  # Explains the marks of the calendar: today, and the anime of the watchlist of a member.
  class CalendarLegendComponent < ViewComponent::Base
    def initialize(watchlist: false)
      @watchlist = watchlist
      super()
    end

    private

    attr_reader :watchlist

    def label = I18n.t("calendar.legend.label")

    def today_label = I18n.t("calendar.legend.today")

    def watchlist_label = I18n.t("calendar.legend.watchlist")
  end
end
