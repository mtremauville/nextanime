require "rails_helper"

RSpec.describe Organisms::SwipeDeckComponent, type: :component do
  subject(:render_deck) { render_inline(described_class.new(animes: animes)) }

  let(:animes) { create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg") }

  it "is a labelled region" do
    render_deck

    expect(page).to have_css("section[aria-label='Deck de cartes']")
  end

  it "renders one card per anime" do
    render_deck

    expect(page).to have_css("article.na-swipe-card", count: 3, visible: :all)
  end

  it "shows the first card only" do
    render_deck

    expect(page).to have_css(".na-swipe-deck__slot article.na-swipe-card", count: 1)
    expect(page).to have_css(".na-swipe-deck__slot[hidden]", count: 2, visible: :all)
  end

  it "starts the progress at the first anime" do
    render_deck

    expect(page).to have_text("Anime 1 / 3")
  end
end
