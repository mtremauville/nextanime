module Molecules
  # On small screens, one chip per day: a link to the block of that day.
  class DayChipsComponent < ViewComponent::Base
    WEEKDAY_FORMAT = "%a".freeze
    NUMBER_FORMAT = "%-d".freeze
    FULL_DAY_FORMAT = "%A %-d %B".freeze

    def initialize(days:)
      @days = days
      super()
    end

    private

    attr_reader :days

    def label = I18n.t("calendar.chips.label")

    def anchor(day) = "#day-#{day.date.iso8601}"

    def chip_class(day) = class_names("na-day-chips__chip", "na-day-chips__chip--today": day.today?)

    def chip_aria(day) = { label: I18n.l(day.date, format: FULL_DAY_FORMAT), current: ("date" if day.today?) }

    def weekday(day) = I18n.l(day.date, format: WEEKDAY_FORMAT).upcase_first

    def number(day) = I18n.l(day.date, format: NUMBER_FORMAT)
  end
end
