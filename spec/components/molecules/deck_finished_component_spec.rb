require "rails_helper"

RSpec.describe Molecules::DeckFinishedComponent, type: :component do
  subject(:render_finished) do
    render_inline(described_class.new(recommendations_href: "/recos", new_session_href: new_session_href))
  end

  let(:new_session_href) { "/" }

  it "keeps the deck id so that it takes the deck's place" do
    render_finished

    expect(page).to have_css("section#swipe-deck.na-swipe-deck")
  end

  it "is announced to assistive technologies" do
    render_finished

    expect(page).to have_css("section[role='status']")
  end

  it "links to the recommendations" do
    render_finished

    expect(page).to have_link("Voir mes recommandations", href: "/recos")
  end

  context "when a new session can be started" do
    it "tells the visitor that the session is over" do
      render_finished

      expect(page).to have_css("h2", text: "Session terminée !")
    end

    it "offers to start a new session" do
      render_finished

      expect(page).to have_link("Nouvelle session", href: "/")
    end
  end

  context "when there is nothing new to draw" do
    let(:new_session_href) { nil }

    it "tells the visitor that every card was seen" do
      render_finished

      expect(page).to have_css("h2", text: "Tu as tout vu !")
    end

    it "offers no new session" do
      render_finished

      expect(page).to have_no_link("Nouvelle session")
    end
  end
end
