require "rails_helper"

RSpec.describe Organisms::CalendarDayComponent, type: :component do
  include ActiveSupport::Testing::TimeHelpers

  let(:friday) { Date.new(2026, 10, 23) }
  let(:saturday) { Date.new(2026, 10, 24) }

  def render_day(date: saturday, airings: [])
    day = AiringCalendar::Day.new(date: date, airings: airings)
    travel_to(Time.zone.local(2026, 10, 23, 12, 0)) { render_inline(described_class.new(day: day)) }
  end

  def anime_airing(title, hour)
    create(:anime, title_romaji: title, title_english: nil, next_episode: 1,
                   next_airing_at: Time.zone.local(2026, 10, 24, hour, 0))
  end

  it "names a day with its weekday and its number" do
    render_day

    expect(page.find("section")["aria-label"]).to eq("Samedi 24")
    expect(page).to have_css("section h2", text: "Samedi 24")
  end

  it "names today as such" do
    render_day(date: friday)

    expect(page.find("section")["aria-label"]).to eq("Aujourd'hui · vendredi 23")
    expect(page).to have_css("section.na-calendar-day--today h2", text: "Aujourd'hui · vendredi 23")
  end

  it "does not mark another day as today" do
    render_day

    expect(page).to have_no_css(".na-calendar-day--today")
  end

  it "can be reached with a link to its anchor" do
    render_day

    expect(page).to have_css("section#day-2026-10-24")
  end

  it "lists the anime that air, in the order it is given them" do
    render_day(airings: [ anime_airing("Early", 17), anime_airing("Late", 22) ])

    expect(page.all("li.na-airing .na-airing__title").map(&:text)).to eq(%w[Early Late])
  end

  it "says when nothing airs" do
    render_day

    expect(page).to have_text("Aucune sortie ce jour-là")
    expect(page).to have_no_css("ul")
  end
end
