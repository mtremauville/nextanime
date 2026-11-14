require "rails_helper"

RSpec.describe Organisms::WhereToWatchComponent, type: :component do
  let(:crunchyroll) { build_stubbed(:streaming_platform, name: "Crunchyroll") }
  let(:netflix) { build_stubbed(:streaming_platform, name: "Netflix") }
  let(:entries) do
    [
      AnimeWhereToWatch::Entry.new(platform: crunchyroll, offer_type: "flatrate", url: "https://www.crunchyroll.com/series/ABC"),
      AnimeWhereToWatch::Entry.new(platform: netflix, offer_type: "ads", url: nil)
    ]
  end

  def render_block(entries: self.entries)
    render_inline(described_class.new(entries: entries, country_label: "France"))
  end

  it "is a region named by its title" do
    render_block

    expect(page).to have_css("section[aria-labelledby='where-to-watch-title']")
    expect(page).to have_css("h2#where-to-watch-title", text: "Où regarder")
  end

  it "names the country" do
    render_block

    expect(page).to have_css(".na-where-to-watch__country", text: "France")
  end

  context "when platforms offer the anime" do
    before { render_block }

    it "lists a row for each offer" do
      expect(page).to have_css("ul.na-where-to-watch__list > li .na-platform-row", count: 2)
    end

    it "says that the anime is available in the country" do
      expect(page).to have_css(".na-where-to-watch__intro", text: "Disponible en streaming en France.")
    end

    it "has no message about a missing offer" do
      expect(page).to have_no_css(".na-where-to-watch__empty")
    end

    it "credits TMDB and JustWatch" do
      expect(page).to have_css(".na-where-to-watch__credit", text: "Disponibilités fournies par TMDB, données JustWatch.")
    end
  end

  context "when no platform offers the anime in the country" do
    before { render_block(entries: []) }

    it "says that it is not available yet there" do
      expect(page).to have_css(".na-where-to-watch__empty-title", text: "Pas encore disponible en France")
      expect(page).to have_css(".na-where-to-watch__empty-text", text: "mises à jour chaque semaine")
    end

    it "shows no list" do
      expect(page).to have_no_css("ul")
    end

    it "still credits TMDB and JustWatch" do
      expect(page).to have_css(".na-where-to-watch__credit", text: "TMDB")
    end
  end
end
