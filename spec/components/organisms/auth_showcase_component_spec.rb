require "rails_helper"

RSpec.describe Organisms::AuthShowcaseComponent, type: :component do
  before { render_inline(described_class.new) }

  it "is decorative, hidden from assistive technologies" do
    expect(page).to have_css(".na-showcase[aria-hidden='true']")
  end

  it "shows the three posters in order" do
    titles = page.all(".na-showcase-poster__title").map(&:text)

    expect(titles).to eq([ "Perfect Blue", "Chainsaw Man", "Eighty-Six" ])
  end

  it "puts the middle poster in front" do
    expect(page).to have_css(".na-showcase-poster--center", text: "Chainsaw Man")
  end
end
