require "rails_helper"

RSpec.describe Organisms::SwipeHistoryPanelComponent, type: :component do
  let(:audience) { :member }

  before { render_inline(described_class.new(audience: audience)) }

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

  it "tells the member that recommendations are already available" do
    expect(page).to have_text("Tu peux déjà voir tes recommandations")
  end

  it "links to the recommendations" do
    expect(page).to have_link("Voir mes recommandations", href: "/recos")
  end

  context "for a visitor" do
    let(:audience) { :visitor }

    it "invites to create an account to keep the swipes and find the recommendations" do
      expect(page).to have_text("Crée un compte pour garder tes swipes et retrouver tes recommandations.")
    end

    it "links to the sign up instead of the recommendations" do
      expect(page).to have_link("Créer un compte", href: "/users/sign_up")
      expect(page).to have_no_link(href: "/recos")
    end
  end

  it "raises for an unknown audience" do
    expect { described_class.new(audience: :stranger) }.to raise_error(ArgumentError)
  end
end
