require "rails_helper"

RSpec.describe Organisms::FinalCallComponent, type: :component do
  before { render_inline(described_class.new) }

  it "is a section named by its heading" do
    expect(page).to have_css("section[aria-labelledby='na-cta-title'] h2#na-cta-title", text: "Prêt à trouver ta vibe ?")
  end

  it "says that no account is needed to start" do
    expect(page).to have_css(".na-cta__text", text: "Aucun compte requis pour commencer.")
  end

  it "leads to the swipe deck, as the main action" do
    expect(page).to have_link("Commencer à swiper", href: "/decouvrir", class: "btn-na-primary")
  end
end
