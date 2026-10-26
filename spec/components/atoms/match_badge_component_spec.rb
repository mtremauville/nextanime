require "rails_helper"

RSpec.describe Atoms::MatchBadgeComponent, type: :component do
  it "renders the percentage with a percent sign" do
    render_inline(described_class.new(percent: 94))

    expect(page).to have_css(".na-badge-match [aria-hidden='true']", text: "94%")
  end

  it "provides an accessible label for screen readers" do
    render_inline(described_class.new(percent: 94))

    expect(page).to have_css(".na-badge-match .visually-hidden", text: "Correspondance de 94 %", visible: :all)
  end

  it "rounds decimal values" do
    render_inline(described_class.new(percent: 93.6))

    expect(page).to have_css("[aria-hidden='true']", text: "94%")
  end

  it "accepts the lower and upper bounds" do
    expect { described_class.new(percent: 0) }.not_to raise_error
    expect { described_class.new(percent: 100) }.not_to raise_error
  end

  it "raises when the percentage is outside 0..100" do
    expect { described_class.new(percent: -1) }.to raise_error(ArgumentError, /between 0 and 100/)
    expect { described_class.new(percent: 101) }.to raise_error(ArgumentError, /between 0 and 100/)
  end
end
