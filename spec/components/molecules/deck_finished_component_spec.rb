require "rails_helper"

RSpec.describe Molecules::DeckFinishedComponent, type: :component do
  before { render_inline(described_class.new(recommendations_href: "/recos")) }

  it "keeps the deck id so that it takes the deck's place" do
    expect(page).to have_css("section#swipe-deck.na-swipe-deck")
  end

  it "is announced to assistive technologies" do
    expect(page).to have_css("section[role='status']")
  end

  it "tells the visitor that every card was seen" do
    expect(page).to have_css("h2", text: "Tu as tout vu !")
  end

  it "links to the recommendations" do
    expect(page).to have_link("Voir mes recommandations", href: "/recos")
  end
end
