require "rails_helper"

RSpec.describe Organisms::SiteFooterComponent, type: :component do
  before { render_inline(described_class.new) }

  it "is the footer of the site" do
    expect(page).to have_css("footer.na-site-footer")
  end

  it "shows the notice that TMDB requires, in English" do
    expect(page).to have_css("p[lang='en']", text: "This product uses the TMDB API but is not endorsed or certified by TMDB.")
  end

  it "credits JustWatch as the source of the streaming availabilities" do
    expect(page).to have_css(".na-site-footer__sources", text: "JustWatch")
    expect(page).to have_link("JustWatch", href: "https://www.justwatch.com/")
  end

  it "credits TMDB and AniList with a link to each" do
    expect(page).to have_link("TMDB", href: "https://www.themoviedb.org/")
    expect(page).to have_link("AniList", href: "https://anilist.co/")
  end

  it "opens every source in a new tab, without giving it access to the page" do
    attributes = page.all(".na-site-footer__sources a").map { |link| [ link[:target], link[:rel] ] }

    expect(attributes.uniq).to eq([ [ "_blank", "noopener noreferrer" ] ])
  end

  it "links to the privacy policy, in the same tab" do
    link = page.find(".na-site-footer").find_link("Confidentialité", href: "/confidentialite")

    expect(link[:target]).to be_nil
  end
end
