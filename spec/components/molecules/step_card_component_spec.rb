require "rails_helper"

RSpec.describe Molecules::StepCardComponent, type: :component do
  def render_card(tone: :magenta)
    render_inline(described_class.new(number: 1, title: "Swipe tes références", tone: tone)) { "Tu likes, tu passes." }
  end

  it "is an item of a list" do
    render_card

    expect(page).to have_css("li.na-step")
  end

  it "shows the number on two digits, hidden from assistive technologies since the list already counts" do
    render_card

    expect(page).to have_css(".na-step__number[aria-hidden='true']", text: "01")
  end

  it "titles the step with a heading" do
    render_card

    expect(page).to have_css("h3.na-step__title", text: "Swipe tes références")
  end

  it "explains the step" do
    render_card

    expect(page).to have_css(".na-step__text", text: "Tu likes, tu passes.")
  end

  it "takes the colour of its tone" do
    render_card(tone: :cyan)

    expect(page).to have_css("li.na-step--cyan")
  end

  it "rejects an unknown tone" do
    expect { described_class.new(number: 1, title: "Titre", tone: :green) }
      .to raise_error(ArgumentError, /Unknown tone/)
  end
end
