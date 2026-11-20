require "rails_helper"

RSpec.describe Organisms::SwipeDeckComponent, type: :component do
  subject(:render_deck) { render_inline(described_class.new(animes: animes, completed: completed)) }

  let(:animes) { create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg") }
  let(:completed) { 0 }

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

  it "starts the progress at 0 %" do
    render_deck

    expect(page).to have_text("0 %")
  end

  it "offers to pass or like the current anime" do
    render_deck

    expect(page).to have_css("button[aria-label='Passer cet anime']")
    expect(page).to have_css("button[aria-label='J\\'aime cet anime']")
  end

  it "is driven by the swipe deck Stimulus controller" do
    render_deck

    expect(page).to have_css(
      "section[data-controller='swipe-deck'][data-swipe-deck-url-value='/swipes']" \
      "[data-swipe-deck-total-value='3'][data-swipe-deck-offset-value='0']"
    )
  end

  it "tells the controller which anime each card holds" do
    render_deck

    animes.each do |anime|
      expect(page).to have_css(
        ".na-swipe-deck__slot[data-swipe-deck-target='slot'][data-anime-id='#{anime.id}']", visible: :all
      )
    end
  end

  it "listens to the arrow keys on the whole page" do
    render_deck

    expect(page).to have_css("section[data-action~='keydown@window->swipe-deck#keydown']")
  end

  it "lets the visitor drag the cards" do
    render_deck

    expect(page).to have_css(
      ".na-swipe-deck__stack[data-swipe-deck-target='stack']" \
      "[data-action~='pointerdown->swipe-deck#dragStart']" \
      "[data-action~='pointerup->swipe-deck#dragEnd']"
    )
  end

  it "can be replaced as a whole through its id" do
    render_deck

    expect(page).to have_css("section#swipe-deck.na-swipe-deck")
  end

  context "when the session is already under way" do
    let(:completed) { 2 }

    it "shows the progress of the whole session" do
      render_deck

      expect(page).to have_text("40 %")
    end

    it "tells the controller how many cards were already swiped" do
      render_deck

      expect(page).to have_css(
        "section[data-swipe-deck-total-value='5'][data-swipe-deck-offset-value='2']"
      )
    end
  end
end
