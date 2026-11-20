require "rails_helper"

RSpec.describe Organisms::FeaturesComponent, type: :component do
  before { render_inline(described_class.new) }

  it "is a section named by a heading" do
    expect(page).to have_css("section[aria-labelledby='na-features-title'] h2#na-features-title", text: "Fonctionnalités")
  end

  it "labels the three features, in order" do
    tags = page.all("ul.na-features > li .na-feature__tag").map(&:text)

    expect(tags).to eq([ "Watchlist", "Calendrier", "Tes goûts d'abord" ])
  end

  it "titles each feature" do
    titles = page.all("ul.na-features > li h3").map(&:text)

    expect(titles).to eq([
      "Une seule liste, toutes les plateformes",
      "Les sorties de la saison au même endroit",
      "La hype passe après toi"
    ])
  end
end
