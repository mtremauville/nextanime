require "rails_helper"

RSpec.describe "The site footer", type: :request do
  let(:document) { Capybara.string(response.body) }
  let(:notice) { "This product uses the TMDB API" }

  it "credits the sources of the data on the catalogue" do
    get catalogue_path

    expect(document).to have_css("footer.na-site-footer", text: notice)
  end

  it "credits them on the page of an anime" do
    get anime_path(create(:anime))

    expect(document).to have_css("footer.na-site-footer", text: notice)
  end

  it "credits them on the watchlist of a member" do
    sign_in create(:user)

    get watchlist_path

    expect(document).to have_css("footer.na-site-footer", text: notice)
  end

  it "offers a member the calendar and the watchlist" do
    sign_in create(:user)

    get catalogue_path

    footer_nav = document.find("footer.na-site-footer nav[aria-label='Pied de page']")
    expect(footer_nav).to have_link("Calendrier", href: calendar_path)
    expect(footer_nav).to have_link("Watchlist", href: watchlist_path)
  end

  it "offers a visitor the pages that are open to everyone" do
    get catalogue_path

    footer_nav = document.find("footer.na-site-footer nav[aria-label='Pied de page']")
    expect(footer_nav).to have_link("Catalogue", href: catalogue_path)
    expect(footer_nav).to have_no_link("Calendrier")
    expect(footer_nav).to have_no_link("Watchlist")
  end

  it "shows the footer once, after the main content" do
    get catalogue_path

    expect(document).to have_css("footer.na-site-footer", count: 1)
    expect(document).to have_css("main#main + footer.na-site-footer")
  end
end
