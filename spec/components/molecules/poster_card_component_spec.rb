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

  it "renders the title as plain text when there is no link" do
    attributes.delete(:href)
    render_card

    expect(page).to have_css("h2", text: "Perfect Blue")
    expect(page).to have_no_link
  end

  describe "reason" do
    it "tells why the anime fits, under the title" do
      render_inline(described_class.new(title: "Monster", reason: "Parce que tu aimes Thriller."))

      expect(page).to have_css("p.na-poster-card__reason", text: "Parce que tu aimes Thriller.")
    end

    it "shows no reason when there is none" do
      render_inline(described_class.new(title: "Monster"))

      expect(page).to have_no_css(".na-poster-card__reason")
    end
  end

  describe "the mark of the watchlist" do
    it "shows it for an anime that is in the list of the member" do
      render_inline(described_class.new(title: "Monster", listed: true))

      expect(page).to have_css(".na-poster-card__listed", text: "Dans ma liste")
    end

    it "shows nothing for an anime that is not" do
      render_inline(described_class.new(title: "Monster"))

      expect(page).to have_no_css(".na-poster-card__listed")
    end

    it "keeps the match next to it" do
      render_inline(described_class.new(title: "Monster", listed: true, match: 87))

      expect(page).to have_css(".na-poster-card__listed")
      expect(page).to have_css(".na-poster-card__badge")
    end
  end
end
