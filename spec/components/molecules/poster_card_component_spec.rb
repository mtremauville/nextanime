require "rails_helper"

RSpec.describe Molecules::PosterCardComponent, type: :component do
  subject(:render_card) { render_inline(described_class.new(**attributes)) }

  let(:attributes) { { title: "Perfect Blue", href: "/animes/1" } }

  it "renders the title as a link that covers the whole card" do
    render_card

    expect(page).to have_link("Perfect Blue", href: "/animes/1", class: "stretched-link")
  end

  it "renders the metadata when given" do
    attributes[:meta] = "Film · 1997 · Madhouse"
    render_card

    expect(page).to have_css("p", text: "Film · 1997 · Madhouse")
  end

  it "renders one tag per label" do
    attributes[:tags] = %w[Thriller Psychologique]
    render_card

    expect(page).to have_css("span.na-tag", count: 2)
    expect(page).to have_css("span.na-tag", text: "Psychologique")
  end

  it "renders the match badge when a percentage is given" do
    attributes[:match] = 94
    render_card

    expect(page).to have_css(".na-badge-match [aria-hidden='true']", text: "94%")
  end

  it "has no match badge without a percentage" do
    render_card

    expect(page).to have_no_css(".na-badge-match")
  end

  it "uses the violet placeholder gradient by default" do
    render_card

    expect(page).to have_css(".na-poster-card__poster.na-poster--violet")
  end

  it "supports another placeholder gradient" do
    attributes[:poster] = :cyan
    render_card

    expect(page).to have_css(".na-poster--cyan")
  end

  it "renders a decorative image instead of the gradient when an image url is given" do
    attributes[:image_url] = "/affiche.jpg"
    render_card

    expect(page).to have_css("img.na-poster-card__image[src='/affiche.jpg'][alt=''][loading='lazy']")
    expect(page).to have_no_css(".na-poster-card__poster")
  end

  it "raises for an unknown placeholder gradient" do
    expect { described_class.new(title: "X", href: "/", poster: :pink) }
      .to raise_error(ArgumentError, /Unknown poster/)
  end
end
