require "rails_helper"

RSpec.describe Atoms::SpinnerComponent, type: :component do
  it "draws a ring that assistive technologies skip" do
    render_inline(described_class.new)

    expect(page).to have_css("span.na-spinner[aria-hidden='true']")
  end

  it "is regular and cyan by default" do
    render_inline(described_class.new)

    expect(page).to have_no_css(".na-spinner--small, .na-spinner--magenta, .na-spinner--dark")
  end

  it "can be small" do
    render_inline(described_class.new(size: :small))

    expect(page).to have_css(".na-spinner.na-spinner--small")
  end

  it "can take the magenta tone" do
    render_inline(described_class.new(tone: :magenta))

    expect(page).to have_css(".na-spinner.na-spinner--magenta")
  end

  it "can take the dark tone, for a spinner on a pink button" do
    render_inline(described_class.new(tone: :dark))

    expect(page).to have_css(".na-spinner.na-spinner--dark")
  end

  it "refuses an unknown size" do
    expect { described_class.new(size: :huge) }.to raise_error(ArgumentError, "Unknown size: :huge")
  end

  it "refuses an unknown tone" do
    expect { described_class.new(tone: :red) }.to raise_error(ArgumentError, "Unknown tone: :red")
  end
end
