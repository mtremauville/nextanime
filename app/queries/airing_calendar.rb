# The anime that air in the coming days, day by day, for the calendar page.
# Only the next episode of each anime is known, so the calendar looks ahead
# from a day and never back.
class AiringCalendar
  DAYS = 7
  MONTHS_PER_SEASON = 3

  Day = Data.define(:date, :airings) do
    def today? = date == Date.current
  end

  def initialize(from: Date.current)
    @first_day = from
  end

  def days
    @days ||= (0...DAYS).map do |offset|
      date = first_day + offset
      Day.new(date: date, airings: airings_by_date.fetch(date, []))
    end
  end

  def empty? = airings.empty?

  # The enum lists the seasons in the order of the year, three months each.
  def season = Anime.seasons.keys.fetch((first_day.month - 1) / MONTHS_PER_SEASON)

  def year = first_day.year

  private

  attr_reader :first_day

  def airings
    @airings ||= Anime.where(next_airing_at: window).order(:next_airing_at, :id).to_a
  end

  # Dates are read in the time zone of the application, so an episode at 00:30 in Paris
  # belongs to the day it airs on there.
  def airings_by_date
    @airings_by_date ||= airings.group_by { |anime| anime.next_airing_at.to_date }
  end

  def window = first_day.beginning_of_day..(first_day + DAYS - 1).end_of_day
end
