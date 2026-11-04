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

  context "with dominant tastes" do
    let(:tastes) do
      [
        TasteProfile::Taste.new(name: "Thriller", weight: 0.9, kind: :genre),
        TasteProfile::Taste.new(name: "Mind Games", weight: 0.6, kind: :tag)
      ]
    end

    before { render_inline(described_class.new(tastes: tastes)) }

    it "lists each taste with its name and its percentage" do
      expect(page).to have_css("[data-role='taste']", count: 2)
      expect(page).to have_css("[data-role='taste']", text: "Thriller")
      expect(page).to have_css("[data-role='taste']", text: "90 %")
      expect(page).to have_css("[data-role='taste']", text: "60 %")
    end

    it "draws a gauge for each taste" do
      expect(page).to have_css("[role='progressbar'][aria-valuenow='90'][aria-label='Thriller']")
      expect(page).to have_css("[role='progressbar'][aria-valuenow='60'][aria-label='Mind Games']")
    end

    it "colours a genre in magenta and a tag in cyan" do
      expect(page.find("[data-role='taste']", text: "Thriller")).to have_no_css(".na-meter__fill--cyan")
      expect(page.find("[data-role='taste']", text: "Mind Games")).to have_css(".na-meter__fill--cyan")
    end

    it "no longer shows the empty message" do
      expect(page).to have_no_text("Swipe quelques animes pour dessiner ton profil.")
    end

    it "can be replaced thanks to its id" do
      expect(page).to have_css("aside#taste-profile-panel")
    end
  end
end
