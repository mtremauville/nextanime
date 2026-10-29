require "rails_helper"

RSpec.describe Organisms::SwipeHistoryPanelComponent, type: :component do
  before { render_inline(described_class.new(recommendations_href: "/recos")) }

  it "is a complementary region named by its heading" do
    expect(page).to have_css("aside[aria-labelledby='swipe-history-title']")
    expect(page).to have_css("h2#swipe-history-title", text: "Ton historique")
  end

  it "introduces the panel with an eyebrow" do
    expect(page).to have_css(".na-eyebrow", text: "Derniers swipes")
  end

  it "explains that the history is empty" do
    expect(page).to have_text("Aucun swipe pour l'instant. Tes choix apparaîtront ici.")
  end

  it "tells the visitor that recommendations are already available" do
    expect(page).to have_text("Tu peux déjà voir tes recommandations")
  end

  it "links to the recommendations" do
    expect(page).to have_link("Voir mes recommandations", href: "/recos")
  end
end
