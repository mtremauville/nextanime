require "rails_helper"

RSpec.describe Organisms::AnimeHeroComponent, type: :component do
  let(:anime) do
    create(:anime, title_romaji: "Chainsaw Man", title_english: nil, title_native: "チェンソーマン",
                   format: :tv, start_date: Date.new(2022, 10, 12), airing_status: :finished, episodes: 12,
                   cover_image_url: "/cover.jpg", banner_image_url: "/banner.jpg",
                   genres: [ create(:genre, name: "Action"), create(:genre, name: "Surnaturel") ])
  end

  def render_hero(subject_anime = anime, **options)
    render_inline(described_class.new(anime: subject_anime, details: AnimeDetails.new(subject_anime), **options))
  end

  it "makes the title the main heading" do
    render_hero

    expect(page).to have_css("h1", text: "Chainsaw Man")
  end

  it "describes the anime above its title" do
    render_hero

    expect(page).to have_css(".na-anime-hero__eyebrow", text: "Série · 2022 · Terminé")
  end

  it "shows the number of episodes under the title" do
    render_hero

    expect(page).to have_css(".na-anime-hero__meta", text: "12 épisodes")
  end

  it "shows every genre as a pill" do
    render_hero

    expect(page).to have_css("span.na-tag", text: "Action")
    expect(page).to have_css("span.na-tag", text: "Surnaturel")
  end

  it "shows the cover and the banner" do
    render_hero

    expect(page).to have_css("img.na-anime-hero__cover[src='/cover.jpg']")
    expect(page).to have_css("img.na-anime-hero__banner-image[src='/banner.jpg']")
  end

  it "falls back on gradients when the anime has no image" do
    render_hero(create(:anime, cover_image_url: nil, banner_image_url: nil))

    expect(page).to have_no_css("img")
    expect(page).to have_css(".na-anime-hero__banner")
    expect(page).to have_css(".na-anime-hero__cover.na-poster--violet")
  end

  it "shows the match panel when the person has a match" do
    render_hero(match_percent: 91, reason: "Parce que tu aimes Action.")

    expect(page).to have_css(".na-match-panel__percent", text: "91%")
    expect(page).to have_text("Parce que tu aimes Action.")
  end

  it "has no match panel without a match" do
    render_hero

    expect(page).to have_no_css(".na-match-panel")
  end

  describe "actions" do
    it "shows the actions the page gives it" do
      render_inline(described_class.new(anime: anime, details: AnimeDetails.new(anime))) do |hero|
        hero.with_actions { "Do something" }
      end

      expect(page).to have_css(".na-anime-hero__actions", text: "Do something")
    end

    it "shows no area for the actions when the page gives none" do
      render_hero

      expect(page).to have_no_css(".na-anime-hero__actions")
    end
  end
end
