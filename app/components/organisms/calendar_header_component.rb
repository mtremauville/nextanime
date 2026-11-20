module Organisms
  # Title block of the calendar page: season, year and the range of days shown.
  class CalendarHeaderComponent < ViewComponent::Base
    DAY_FORMAT = "%-d".freeze
    DAY_AND_MONTH_FORMAT = "%-d %B".freeze
    MONTH_FORMAT = "%B".freeze

    def initialize(calendar:)
      @calendar = calendar
      super()
    end

    private

    attr_reader :calendar

    def eyebrow = I18n.t("calendar.header.eyebrow")

    def title
      I18n.t("calendar.header.title", season: I18n.t("calendar.season.#{calendar.season}"), year: calendar.year)
    end

    def range
      first_date = calendar.days.first.date
      last_date = calendar.days.last.date
      first_date.month == last_date.month ? one_month_range(first_date, last_date) : two_months_range(first_date, last_date)
    end

    def one_month_range(first_date, last_date)
      I18n.t("calendar.header.range.one_month",
             from: I18n.l(first_date, format: DAY_FORMAT),
             to: I18n.l(last_date, format: DAY_FORMAT),
             month: I18n.l(last_date, format: MONTH_FORMAT))
    end

    def two_months_range(first_date, last_date)
      I18n.t("calendar.header.range.two_months",
             from: I18n.l(first_date, format: DAY_AND_MONTH_FORMAT),
             to: I18n.l(last_date, format: DAY_AND_MONTH_FORMAT))
    end
  end
end
