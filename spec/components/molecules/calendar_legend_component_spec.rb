require "rails_helper"

RSpec.describe Molecules::CalendarLegendComponent, type: :component do
  it "is a list named after what it explains" do
    render_inline(described_class.new)

    expect(page).to have_css("ul.na-calendar-legend[aria-label='Légende']")
  end

  it "explains the mark of today" do
    render_inline(described_class.new)

    expect(page).to have_css("li.na-calendar-legend__item", text: "Aujourd'hui")
  end

  it "explains the mark of the watchlist" do
    render_inline(described_class.new)

    expect(page).to have_css("li.na-calendar-legend__item", text: "Dans ma watchlist")
  end
end
