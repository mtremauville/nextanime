require "rails_helper"

RSpec.describe Organisms::WatchlistSummaryComponent, type: :component do
  let(:entry) { create(:watchlist_entry, :watching, progress: 14) }

  def render_summary(global_percent: 68, resume_entry: nil)
    render_inline(described_class.new(global_percent: global_percent, resume_entry: resume_entry))
  end

  it "shows the overall progress with a bar" do
    render_summary

    expect(page).to have_css(".na-watch-summary__percent", text: "68%")
    expect(page).to have_css("[role=progressbar][aria-valuenow='68']")
  end

  it "leaves out the overall progress while it is unknown" do
    render_summary(global_percent: nil)

    expect(page).to have_no_text("Avancement global")
    expect(page).to have_no_css("[role=progressbar]")
  end

  it "invites to resume at the episode after the last one watched" do
    render_summary(resume_entry: entry)

    expect(page).to have_text("Tu en étais à l'épisode 15 de #{entry.anime.display_title}")
  end

  it "links to the page of the anime to resume" do
    render_summary(resume_entry: entry)

    expect(page).to have_link("Voir la fiche", href: Rails.application.routes.url_helpers.anime_path(entry.anime))
  end

  it "has nothing to resume without an entry being watched" do
    render_summary

    expect(page).to have_no_text("Reprendre")
  end

  it "renders nothing when there is nothing to say" do
    render_summary(global_percent: nil, resume_entry: nil)

    expect(page).to have_no_css("aside")
  end
end
