require "rails_helper"

RSpec.describe Organisms::CatalogueGridComponent, type: :component do
  it "is the list a turbo stream adds the next anime to" do
    render_inline(described_class.new(animes: []))

    expect(page).to have_css("ul##{described_class::DOM_ID}")
  end

  it "holds the items of the anime it is given" do
    animes = [ create(:anime, title_english: "Monster"), create(:anime, title_english: "Frieren") ]

    render_inline(described_class.new(animes: animes))

    expect(page).to have_css("ul##{described_class::DOM_ID} li[data-role='catalogue-item']", count: 2)
  end

  it "passes the scorer to the items" do
    scorer = instance_double(MatchScorer, percentage: 91)

    render_inline(described_class.new(animes: [ create(:anime) ], scorer: scorer))

    expect(page).to have_css(".na-badge-match [aria-hidden='true']", text: "91%")
  end

  describe "the anime of the watchlist" do
    it "hands the ids to its cards" do
      monster = create(:anime, title_romaji: "Monster", title_english: nil)

      render_inline(described_class.new(animes: [ monster ], listed_ids: Set.new([ monster.id ])))

      expect(page).to have_css("#catalogue-grid .na-poster-card__listed", count: 1)
    end
  end
end
