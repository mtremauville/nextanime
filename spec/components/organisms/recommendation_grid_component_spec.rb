require "rails_helper"

RSpec.describe Organisms::RecommendationGridComponent, type: :component do
  subject(:render_grid) { render_inline(described_class.new(recommendations: recommendations)) }

  let(:perfect_blue) do
    create(:anime, title_romaji: "Perfect Blue", title_english: nil, format: :movie, start_date: Date.new(1997, 8, 5),
                   cover_image_url: "/perfect-blue.jpg", genres: [ create(:genre, name: "Thriller") ])
  end
  let(:monster) { create(:anime, title_romaji: "Monster", title_english: nil, format: :tv) }
  let(:recommendations) do
    [ Recommendation.new(anime: perfect_blue, score: 0.94), Recommendation.new(anime: monster, score: 0.8) ]
  end

  it "renders one item per recommendation" do
    render_grid

    expect(page).to have_css("[data-role='recommendation']", count: 2)
  end

  it "keeps the order it was given" do
    render_grid

    expect(page.all("h2").map { |heading| heading.text.strip }).to eq([ "Perfect Blue", "Monster" ])
  end

  it "shows the match as a percentage" do
    render_grid

    expect(page).to have_css(".na-badge-match [aria-hidden='true']", text: "94%")
    expect(page).to have_css(".na-badge-match [aria-hidden='true']", text: "80%")
  end

  it "describes the anime in one line" do
    render_grid

    expect(page).to have_css("p", text: "Film · 1997")
  end

  it "shows the genres as pills" do
    render_grid

    expect(page).to have_css("span.na-tag", text: "Thriller")
  end

  it "shows the cover" do
    render_grid

    expect(page).to have_css("img.na-poster-card__image[src='/perfect-blue.jpg']")
  end

  it "does not link to a page that does not exist yet" do
    render_grid

    expect(page).to have_no_link
  end
end
