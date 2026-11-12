require "rails_helper"

RSpec.describe Organisms::CalendarHeaderComponent, type: :component do
  def render_header(from)
    render_inline(described_class.new(calendar: AiringCalendar.new(from: from)))
  end

  it "shows the eyebrow of the page" do
    render_header(Date.new(2026, 10, 23))

    expect(page).to have_css("header p", text: "Simulcast")
  end

  it "titles the page with the season and the year" do
    render_header(Date.new(2026, 10, 23))

    expect(page).to have_css("h1", text: "Automne 2026")
  end

  it "names the other seasons too" do
    render_header(Date.new(2027, 1, 5))
    expect(page).to have_css("h1", text: "Hiver 2027")

    render_header(Date.new(2026, 7, 10))
    expect(page).to have_css("h1", text: "Été 2026")
  end

  it "gives the range of the seven days when they stay in one month" do
    render_header(Date.new(2026, 10, 23))

    expect(page).to have_text("Du 23 au 29 octobre")
  end

  it "gives both months when the seven days span two months" do
    render_header(Date.new(2026, 10, 28))

    expect(page).to have_text("Du 28 octobre au 3 novembre")
  end
end
