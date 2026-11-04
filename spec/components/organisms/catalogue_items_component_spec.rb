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
end
