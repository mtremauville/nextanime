class CalendarController < ApplicationController
  def show
    @calendar = AiringCalendar.new
  end
end
