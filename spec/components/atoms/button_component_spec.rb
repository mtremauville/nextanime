require "rails_helper"

RSpec.describe Atoms::ButtonComponent, type: :component do
  it "renders a button with its label" do
    render_inline(described_class.new) { "Découvrir" }

    expect(page).to have_button("Découvrir", type: "button")
  end

  it "uses the primary variant by default" do
    render_inline(described_class.new) { "Découvrir" }

    expect(page).to have_css("button.btn.btn-na-primary")
  end

  it "supports the outline variant" do
    render_inline(described_class.new(variant: :outline)) { "Voir la fiche" }

    expect(page).to have_css("button.btn.btn-na-outline")
  end

  it "supports the submit type" do
    render_inline(described_class.new(type: "submit")) { "Créer mon compte" }

    expect(page).to have_css("button[type='submit']")
  end

  it "renders a link styled as a button when an href is given" do
    render_inline(described_class.new(href: "/catalogue", variant: :outline)) { "Catalogue" }

    expect(page).to have_link("Catalogue", href: "/catalogue", class: "btn-na-outline")
  end

  it "passes extra attributes to the element" do
    render_inline(described_class.new(aria: { label: "Aimer" }, data: { action: "swipe#like" })) { "♥" }

    expect(page).to have_css("button[aria-label='Aimer'][data-action='swipe#like']")
  end

  it "merges a custom class with the variant classes" do
    render_inline(described_class.new(class: "w-100")) { "Découvrir" }

    expect(page).to have_css("button.btn-na-primary.w-100")
  end

  it "raises for an unknown variant" do
    expect { described_class.new(variant: :neon) }.to raise_error(ArgumentError, /Unknown variant/)
  end

  it "supports the ghost variant" do
    render_inline(described_class.new(variant: :ghost)) { "Réinitialiser" }

    expect(page).to have_css("button.btn.btn-na-ghost")
  end
end
