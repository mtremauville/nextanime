require "rails_helper"

RSpec.describe Organisms::WhereToWatchComponent, type: :component do
  let(:crunchyroll) { build_stubbed(:streaming_platform, name: "Crunchyroll") }
  let(:netflix) { build_stubbed(:streaming_platform, name: "Netflix") }
  let(:tmdb_page) { "https://www.themoviedb.org/tv/1/watch?locale=FR" }
  let(:entries) do
    [
      AnimeWhereToWatch::Entry.new(platform: crunchyroll, offer_types: %w[flatrate], url: "https://www.crunchyroll.com/series/ABC"),
      AnimeWhereToWatch::Entry.new(platform: netflix, offer_types: %w[ads], url: nil)
    ]
  end

  def render_block(entries: self.entries, tmdb_page_url: tmdb_page)
    render_inline(described_class.new(entries: entries, country_label: "France", tmdb_page_url: tmdb_page_url))
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

  describe "the link to the watch page of TMDB" do
    it "opens the page in a new tab safely" do
      render_block

      expect(page).to have_css(
        ".na-where-to-watch__credit a[href='#{tmdb_page}'][target='_blank'][rel='noopener noreferrer']",
        text: "Voir toutes les offres sur TMDB"
      )
    end

    it "tells screen readers that the link opens a new tab" do
      render_block

      expect(page).to have_css(".na-where-to-watch__credit a .visually-hidden", text: "(s'ouvre dans un nouvel onglet)")
    end

    it "is also shown when no platform offers the anime" do
      render_block(entries: [])

      expect(page).to have_css(".na-where-to-watch__credit a[href='#{tmdb_page}']")
    end

    it "is not shown when TMDB has no page for the country" do
      render_block(tmdb_page_url: nil)

      expect(page).to have_no_css(".na-where-to-watch__credit a")
    end

    it "is not a link when the address is not a web address" do
      render_block(tmdb_page_url: "javascript:alert(1)")

      expect(page).to have_no_css(".na-where-to-watch__credit a")
    end
  end
end
