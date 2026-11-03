require "rails_helper"

RSpec.describe Atoms::MeterComponent, type: :component do
  it "exposes a progressbar with its value and an accessible name" do
    render_inline(described_class.new(value: 82, label: "Thriller"))

    expect(page).to have_css(
      "div.na-meter[role='progressbar'][aria-valuenow='82'][aria-valuemin='0'][aria-valuemax='100'][aria-label='Thriller']"
    )
  end

  it "sets the fill width through a modifier class" do
    render_inline(described_class.new(value: 82, label: "Thriller"))

    expect(page).to have_css(".na-meter__fill.na-meter__fill--82")
  end

  it "rounds decimal values" do
    render_inline(described_class.new(value: 81.6, label: "Thriller"))

    expect(page).to have_css(".na-meter__fill--82")
  end

  it "uses the magenta tone by default" do
    render_inline(described_class.new(value: 40, label: "Action"))

    expect(page).to have_no_css(".na-meter__fill--cyan")
  end

  it "supports the cyan tone" do
    render_inline(described_class.new(value: 40, label: "Action", tone: :cyan))

    expect(page).to have_css(".na-meter__fill.na-meter__fill--cyan")
  end

  it "raises when the value is outside 0..100" do
    expect { described_class.new(value: 101, label: "Action") }.to raise_error(ArgumentError, /between 0 and 100/)
    expect { described_class.new(value: -1, label: "Action") }.to raise_error(ArgumentError, /between 0 and 100/)
  end

  it "raises for an unknown tone" do
    expect { described_class.new(value: 10, label: "Action", tone: :green) }.to raise_error(ArgumentError, /Unknown tone/)
  end
end
