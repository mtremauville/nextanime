require "rails_helper"

RSpec.describe Molecules::WatchlistRowComponent, type: :component do
  def render_row(status: "watching", progress: 14, episodes: 28, cover_image_url: nil)
    anime = create(:anime, episodes: episodes, cover_image_url: cover_image_url)
    entry = create(:watchlist_entry, status: status, progress: progress, anime: anime)
    render_inline(described_class.new(entry: entry))
    entry
  end

  it "links the title to the page of the anime" do
    entry = render_row

    expect(page).to have_link(entry.anime.display_title, href: Rails.application.routes.url_helpers.anime_path(entry.anime))
  end

  it "sums the anime up under its title" do
    entry = render_row
    line = AnimeSummary.new(entry.anime).line

    expect(line).to be_present
    expect(page).to have_css(".na-watch-row__meta", text: line)
  end

  it "shows a cyan status for what is still to watch" do
    render_row(status: "plan_to_watch", progress: 0)

    expect(page).to have_css(".na-tag.na-tag--cyan", text: "À voir")
  end

  it "shows a magenta status for what is being watched" do
    render_row

    expect(page).to have_css(".na-tag", text: "En cours")
    expect(page).to have_no_css(".na-tag--cyan, .na-tag--muted")
  end

  it "shows a muted status, and a muted bar, for what is done" do
    render_row(status: "completed", progress: 28)

    expect(page).to have_css(".na-tag.na-tag--muted", text: "Terminé")
    expect(page).to have_css(".na-meter__fill--muted")
  end

  it "shows the episodes watched out of the total, with the percentage" do
    render_row

    expect(page).to have_css(".na-watch-row__count", text: "ÉP. 14 / 28")
    expect(page).to have_css(".na-watch-row__count", text: "50%")
  end

  it "shows the progress as a bar" do
    render_row

    expect(page).to have_css("[role=progressbar][aria-valuenow='50']")
  end

  it "shows only the episodes watched when the total is unknown" do
    render_row(progress: 5, episodes: nil)

    expect(page).to have_css(".na-watch-row__count", text: "ÉP. 5")
    expect(page).to have_no_text("/")
    expect(page).to have_no_text("%")
    expect(page).to have_no_css("[role=progressbar]")
  end

  it "shows the cover of the anime" do
    render_row(cover_image_url: "https://img.example/frieren.jpg")

    expect(page).to have_css("img.na-watch-row__image[src='https://img.example/frieren.jpg']")
  end

  it "falls back to a coloured poster without a cover" do
    render_row

    expect(page).to have_css(".na-watch-row__poster.na-poster--violet")
    expect(page).to have_no_css("img")
  end

  it "shows what is put in its actions slot" do
    entry = create(:watchlist_entry, :watching, anime: create(:anime, episodes: 12))

    render_inline(described_class.new(entry: entry)) { |row| row.with_actions { "Mes boutons" } }

    expect(page).to have_css(".na-watch-row__actions", text: "Mes boutons")
  end

  it "has no actions area without an actions slot" do
    render_row

    expect(page).to have_no_css(".na-watch-row__actions")
  end
end
