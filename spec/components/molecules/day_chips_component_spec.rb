require "rails_helper"

RSpec.describe Molecules::DayChipsComponent, type: :component do
  include ActiveSupport::Testing::TimeHelpers

  let(:friday) { Date.new(2026, 10, 23) }
  let(:days) { AiringCalendar.new(from: friday).days }

  before do
    travel_to(Time.zone.local(2026, 10, 23, 12, 0)) { render_inline(described_class.new(days: days)) }
  end

  it "is a navigation named after what it does" do
    expect(page).to have_css("nav[aria-label='Choisir un jour']")
  end

  it "has a link for each of the days, with its weekday and its number" do
    links = page.all("nav a")

    expect(links.size).to eq(7)
    expect(links.first(2).map { |link| link.text(normalize_ws: true) }).to eq([ "Ven 23", "Sam 24" ])
  end

  it "leads each link to the block of its day" do
    expect(page).to have_css("a[href='#day-2026-10-23']")
    expect(page).to have_css("a[href='#day-2026-10-29']")
  end

  it "names each day in full for assistive technologies" do
    expect(page).to have_css("a[href='#day-2026-10-23'][aria-label='vendredi 23 octobre']")
  end

  it "marks only today as the current date" do
    expect(page).to have_css("a[aria-current='date']", count: 1)
    expect(page).to have_css("a[href='#day-2026-10-23'][aria-current='date']")
  end
end
