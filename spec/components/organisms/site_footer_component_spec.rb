require "rails_helper"

RSpec.describe Organisms::SiteFooterComponent, type: :component do
  include ActiveSupport::Testing::TimeHelpers

  let(:audience) { :member }
  let(:routes) { Rails.application.routes.url_helpers }
  let(:footer_nav) { page.find("footer nav[aria-label='Pied de page']") }

  around { |example| travel_to(Time.zone.local(2027, 1, 5)) { example.run } }

  before { render_inline(described_class.new(audience: audience)) }

  it "is the footer of the site" do
    expect(page).to have_css("footer.na-site-footer")
  end

  it "credits AniList for the data, next to the name of the site" do
    expect(page).to have_css(".na-site-footer__copyright", text: "NextAnime · Données fournies par AniList")
    expect(page).to have_link("AniList", href: "https://anilist.co/")
  end

  it "states the current year" do
    expect(page).to have_css(".na-site-footer__copyright", text: "© 2027")
  end

  it "links a member to the discovery, the calendar and the watchlist" do
    expect(footer_nav).to have_link("Découvrir", href: routes.discover_path)
    expect(footer_nav).to have_link("Calendrier", href: routes.calendar_path)
    expect(footer_nav).to have_link("Watchlist", href: routes.watchlist_path)
  end

  context "for a visitor" do
    let(:audience) { :visitor }

    it "links to the discovery and the catalogue only" do
      expect(footer_nav).to have_link("Découvrir", href: routes.discover_path)
      expect(footer_nav).to have_link("Catalogue", href: routes.catalogue_path)
      expect(footer_nav).to have_no_link("Calendrier")
      expect(footer_nav).to have_no_link("Watchlist")
    end
  end

  it "refuses an audience it does not know" do
    expect { described_class.new(audience: :admin) }.to raise_error(ArgumentError, /unknown audience/)
  end

  it "shows the notice that TMDB requires, in English" do
    expect(page).to have_css("p[lang='en']", text: "This product uses the TMDB API but is not endorsed or certified by TMDB.")
  end

  it "credits JustWatch as the source of the streaming availabilities" do
    expect(page).to have_css(".na-site-footer__sources", text: "JustWatch")
    expect(page).to have_link("JustWatch", href: "https://www.justwatch.com/")
    expect(page).to have_link("TMDB", href: "https://www.themoviedb.org/")
  end

  it "opens every source in a new tab, without giving it access to the page" do
    links = page.all("a[target='_blank']")

    expect(links.map(&:text)).to contain_exactly("AniList", "JustWatch", "TMDB")
    expect(links.map { |link| [ link[:target], link[:rel] ] }.uniq).to eq([ [ "_blank", "noopener noreferrer" ] ])
  end

  it "links to the privacy policy, in the same tab" do
    link = page.find(".na-site-footer").find_link("Confidentialité", href: "/confidentialite")

    expect(link[:target]).to be_nil
  end
end
