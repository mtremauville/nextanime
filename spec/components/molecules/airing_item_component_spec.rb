require "rails_helper"

RSpec.describe Molecules::AiringItemComponent, type: :component do
  let(:anime) do
    create(:anime, title_romaji: "Sousou no Frieren", title_english: "Frieren",
                   cover_image_url: "https://img.example/frieren.jpg",
                   next_episode: 4, next_airing_at: Time.zone.local(2026, 10, 23, 20, 0))
  end

  def render_item(airing = anime) = render_inline(described_class.new(anime: airing))

  it "links the displayed title to the anime" do
    render_item

    expect(page).to have_link("Frieren", href: "/anime/#{anime.id}")
  end

  it "tells which episode airs" do
    render_item

    expect(page).to have_text("Épisode 4")
  end

  it "shows the time in Paris, in a time element a machine can read" do
    render_item

    expect(page).to have_css("time[datetime='2026-10-23T20:00:00+02:00']", text: "20:00")
  end

  it "shows the poster, which is only decoration next to the title" do
    render_item

    expect(page).to have_css("img.na-airing__poster[src='https://img.example/frieren.jpg'][alt=''][loading='lazy']")
  end

  it "shows a colored block when the anime has no poster" do
    render_item(create(:anime, cover_image_url: nil, next_episode: 1, next_airing_at: Time.zone.local(2026, 10, 23, 20, 0)))

    expect(page).to have_no_css("img")
    expect(page).to have_css("div.na-airing__poster.na-poster--violet")
  end
end
