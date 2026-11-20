require "rails_helper"

RSpec.describe Molecules::SwipeCardComponent, type: :component do
  subject(:render_card) { render_inline(described_class.new(anime: anime)) }

  let(:anime) do
    create(
      :anime,
      title_romaji: "Jujutsu Kaisen",
      title_english: "Jujutsu Kaisen",
      cover_image_url: "https://img.test/jjk.jpg",
      format: :tv,
      start_date: Date.new(2020, 10, 3),
      episodes: 24
    )
  end

  before do
    create(:anime_studio, anime: anime, studio: create(:studio, name: "MAPPA"), main: true)
  end

  it "renders the title" do
    render_card

    expect(page).to have_css("h2", text: "Jujutsu Kaisen")
  end

  it "renders the cover as a decorative image" do
    render_card

    expect(page).to have_css("img[src='https://img.test/jjk.jpg'][alt='']")
  end

  it "tells the format and the year" do
    render_card

    expect(page).to have_css(".na-swipe-card__badge", text: "Série · 2020")
  end

  it "tells the main studio and the number of episodes" do
    render_card

    expect(page).to have_css(".na-swipe-card__meta", text: "MAPPA · 24 épisodes")
  end

  it "uses the singular for a single episode" do
    anime.update!(episodes: 1)
    render_card

    expect(page).to have_css(".na-swipe-card__meta", text: "MAPPA · 1 épisode")
  end

  it "shows the first three genres only" do
    %w[Action Surnaturel Shōnen Comédie].each { |name| anime.genres << create(:genre, name: name) }
    render_card

    expect(page).to have_css("span.na-tag", count: 3)
    expect(page).to have_no_css("span.na-tag", text: "Comédie")
  end

  context "without format nor start date" do
    it "shows no badge" do
      anime.update!(format: nil, start_date: nil)
      render_card

      expect(page).to have_no_css(".na-swipe-card__badge")
    end
  end

  context "without studio nor episodes" do
    it "shows no metadata" do
      anime.anime_studios.destroy_all
      anime.update!(episodes: nil)
      render_card

      expect(page).to have_no_css(".na-swipe-card__meta")
    end
  end
end
