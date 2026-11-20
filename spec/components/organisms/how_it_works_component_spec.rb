require "rails_helper"

RSpec.describe Organisms::HowItWorksComponent, type: :component do
  before { render_inline(described_class.new) }

  it "is a section named by its heading" do
    expect(page).to have_css("section[aria-labelledby='na-how-title'] h2#na-how-title", text: "De tes goûts à tes découvertes")
  end

  it "introduces the section with a label" do
    expect(page).to have_css(".na-eyebrow", text: "Comment ça marche")
  end

  it "lists the three steps, in order" do
    titles = page.all("ol.na-steps > li h3").map(&:text)

    expect(titles).to eq([ "Swipe tes références", "On cerne ta vibe", "Trouve ton match" ])
  end

  it "numbers the steps from 01 to 03" do
    expect(page.all(".na-step__number").map(&:text)).to eq(%w[01 02 03])
  end
end
