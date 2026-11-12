module Organisms
  # One day of the calendar: its title and the anime that air on it.
  class CalendarDayComponent < ViewComponent::Base
    DAY_FORMAT = "%A %-d".freeze
    WEEKDAY_FORMAT = "%A".freeze
    NUMBER_FORMAT = "%-d".freeze
    MONTH_FORMAT = "%b".freeze

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

    def today_mark = I18n.t("calendar.day.today_mark")

    def name = day.today? ? weekday : weekday.upcase_first

    def weekday = I18n.l(day.date, format: WEEKDAY_FORMAT)

    def number = I18n.l(day.date, format: NUMBER_FORMAT)

    def month = I18n.l(day.date, format: MONTH_FORMAT)

    def nothing_airs_label = I18n.t("calendar.day.none")
  end
end
