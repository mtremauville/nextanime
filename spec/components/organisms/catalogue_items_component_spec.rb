require "rails_helper"

RSpec.describe Organisms::CatalogueItemsComponent, type: :component do
  let(:monster) { create(:anime, title_english: "Monster", cover_image_url: "https://img.test/monster.jpg") }
  let(:scorer) { instance_double(MatchScorer, percentage: 87) }

  def render_items(animes:, scorer: nil)
    render_inline(described_class.new(animes: animes, scorer: scorer))
  end

  it "renders one item for each anime" do
    render_items(animes: [ monster, create(:anime, title_english: "Frieren") ])

    expect(page).to have_css("li[data-role='catalogue-item']", count: 2)
  end

  it "links each card to the page of its anime" do
    render_items(animes: [ monster ])

    expect(page).to have_link("Monster", href: "/anime/#{monster.id}")
  end

  it "shows the match of each anime when it has a scorer" do
    render_items(animes: [ monster ], scorer: scorer)

    expect(page).to have_css(".na-badge-match [aria-hidden='true']", text: "87%")
    expect(scorer).to have_received(:percentage).with(monster)
  end

  it "shows no match without a scorer" do
    render_items(animes: [ monster ])

    expect(page).to have_no_css(".na-badge-match")
  end

  it "renders nothing for no anime" do
    render_items(animes: [])

    expect(page).to have_no_css("li")
  end

  describe "the anime of the watchlist" do
    it "marks the anime whose id it is given, and only them" do
      monster = create(:anime, title_romaji: "Monster", title_english: nil)
      pluto = create(:anime, title_romaji: "Pluto", title_english: nil)

      render_inline(described_class.new(animes: [ monster, pluto ], listed_ids: Set.new([ monster.id ])))

      expect(page.find("li", text: "Monster")).to have_css(".na-poster-card__listed")
      expect(page.find("li", text: "Pluto")).to have_no_css(".na-poster-card__listed")
    end
  end
end
