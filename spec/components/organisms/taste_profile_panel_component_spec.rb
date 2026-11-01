require "rails_helper"

RSpec.describe Organisms::TasteProfilePanelComponent, type: :component do
  context "without a link to the full profile" do
    before { render_inline(described_class.new) }

    it "is a complementary region named by its heading" do
      expect(page).to have_css("aside[aria-labelledby='taste-profile-title']")
      expect(page).to have_css("h2#taste-profile-title", text: "Genres et ambiances")
    end

    it "introduces the panel with an eyebrow" do
      expect(page).to have_css(".na-eyebrow", text: "Ton profil se dessine")
    end

    it "invites the visitor to swipe while the profile is empty" do
      expect(page).to have_text("Swipe quelques animes pour dessiner ton profil.")
    end

    it "shows no link" do
      expect(page).to have_no_link
    end
  end

  context "with a link to the full profile" do
    before { render_inline(described_class.new(href: "/profile")) }

    it "links to the full profile" do
      expect(page).to have_link("Voir mon profil complet", href: "/profile")
    end
  end

  context "with a custom label" do
    before { render_inline(described_class.new(href: "/users/sign_up", label: "Sauvegarder mon profil →")) }

    it "uses the label for the link" do
      expect(page).to have_link("Sauvegarder mon profil →", href: "/users/sign_up")
    end

    it "no longer offers the default label" do
      expect(page).to have_no_link("Voir mon profil complet")
    end
  end
end

RSpec.describe Organisms::TasteProfilePanelComponent, "with a way to reset", type: :component do
  before { render_inline(described_class.new(reset_href: "/taste_profile/reset")) }

  it "offers a button that opens the confirmation" do
    expect(page).to have_css("button[data-action='confirm-modal#open']", text: "Réinitialiser mon profil")
  end

  it "asks before erasing anything" do
    expect(page).to have_css("dialog h2", text: "Réinitialiser ton profil de goûts ?")
  end

  it "explains that the watchlist and the account stay" do
    expect(page).to have_css("dialog", text: "Ta watchlist et ton compte ne changent pas.")
  end

  it "confirms with a DELETE request to the given address" do
    expect(page).to have_css("dialog form[action='/taste_profile/reset']")
    expect(page).to have_css("dialog form input[name='_method'][value='delete']", visible: :all)
  end
end

RSpec.describe Organisms::TasteProfilePanelComponent, "without a way to reset", type: :component do
  before { render_inline(described_class.new) }

  it "offers no confirmation" do
    expect(page).to have_no_css("dialog")
    expect(page).to have_no_button("Réinitialiser mon profil")
  end
end
