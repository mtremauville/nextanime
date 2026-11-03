require "rails_helper"

RSpec.describe Organisms::RecommendationsHeaderComponent, type: :component do
  subject(:render_header) { render_inline(described_class.new(**attributes)) }

  let(:attributes) { { tags: %w[Psychologique], genres: %w[Action Surnaturel], swipe_href: "/" } }

  it "renders the title as the main heading" do
    render_header

    expect(page).to have_css("h1", text: "Tes recommandations")
  end

  it "renders the eyebrow" do
    render_header

    expect(page).to have_css("p", text: "Ton match")
  end

  it "renders a magenta pill per tag" do
    render_header

    expect(page).to have_css("span.na-tag:not(.na-tag--cyan)", text: "Psychologique", count: 1)
  end

  it "renders a cyan pill per genre" do
    render_header

    expect(page).to have_css("span.na-tag.na-tag--cyan", count: 2)
    expect(page).to have_css("span.na-tag--cyan", text: "Surnaturel")
  end

  it "renders no pill while the taste is unknown" do
    attributes.merge!(tags: [], genres: [])
    render_header

    expect(page).to have_no_css(".na-tag")
  end

  it "links to keep on swiping" do
    render_header

    expect(page).to have_link("Continuer à swiper", href: "/")
  end

  it "links to the profile when it has a page" do
    attributes[:profile_href] = "/profil"
    render_header

    expect(page).to have_link("Ton profil", href: "/profil")
  end

  it "has no link to the profile otherwise" do
    render_header

    expect(page).to have_no_link("Ton profil")
  end
end
