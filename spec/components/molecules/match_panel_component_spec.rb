require "rails_helper"

RSpec.describe Molecules::MatchPanelComponent, type: :component do
  it "shows the match as a percentage" do
    render_inline(described_class.new(percent: 91))

    expect(page).to have_css(".na-match-panel__percent", text: "91%")
    expect(page).to have_css(".na-match-panel__label", text: "de match")
  end

  it "gives the reason of the match under its own heading" do
    render_inline(described_class.new(percent: 91, reason: "Parce que tu aimes Thriller."))

    expect(page).to have_css("h2", text: "Pourquoi ce match")
    expect(page).to have_css("p", text: "Parce que tu aimes Thriller.")
  end

  it "has no reason block when nothing explains the match" do
    render_inline(described_class.new(percent: 91))

    expect(page).to have_no_css("h2")
    expect(page).to have_no_text("Pourquoi ce match")
  end
end
