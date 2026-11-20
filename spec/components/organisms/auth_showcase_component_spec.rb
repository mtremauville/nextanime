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
  context "with the covers of the anime" do
    before do
      render_inline(described_class.new(image_urls: {
        perfect_blue: "https://img.test/perfect-blue.jpg",
        eighty_six: "https://img.test/eighty-six.jpg"
      }))
    end

    it "shows the cover of each poster that has one, in order" do
      sources = page.all("img.na-showcase-poster__image").map { |image| image[:src] }

      expect(sources).to eq([ "https://img.test/perfect-blue.jpg", "https://img.test/eighty-six.jpg" ])
    end

    it "keeps the three posters, the one without a cover keeping its gradient" do
      expect(page).to have_css(".na-showcase-poster", count: 3)
    end
  end
end
