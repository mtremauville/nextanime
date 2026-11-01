require "rails_helper"

RSpec.describe Molecules::StatCardComponent, type: :component do
  def render_card(**options)
    render_inline(described_class.new(stat: :swipes, value: 24, label: "Cartes swipées", **options))
  end

  it "shows the value, marked with the name of the stat" do
    render_card

    expect(page).to have_css("[data-stat=swipes]", exact_text: "24")
  end

  it "names what the value counts" do
    render_card

    expect(page).to have_css(".na-stat-card__label", text: "Cartes swipées")
  end

  it "gives the value the requested tone" do
    render_card(tone: :magenta)

    expect(page).to have_css(".na-stat-card__value--magenta")
  end

  it "uses the neutral tone by default" do
    render_card

    expect(page).to have_css(".na-stat-card__value--default")
  end
end
