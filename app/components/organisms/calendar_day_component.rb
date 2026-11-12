module Organisms
  # One day of the calendar: its title and the anime that air on it.
  class CalendarDayComponent < ViewComponent::Base
    DAY_FORMAT = "%A %-d".freeze

    def initialize(day:)
      @day = day
      super()
    end

    private

    attr_reader :day

    def anchor = "day-#{day.date.iso8601}"

    def css_class = class_names("na-calendar-day", "na-calendar-day--today": day.today?)

    def label
      return I18n.t("calendar.day.today", day: weekday_and_number) if day.today?

      weekday_and_number.upcase_first
    end

    def weekday_and_number = I18n.l(day.date, format: DAY_FORMAT)

    def nothing_airs_label = I18n.t("calendar.day.none")
  end
end
