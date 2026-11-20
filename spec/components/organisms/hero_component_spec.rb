require "rails_helper"

RSpec.describe Organisms::HeroComponent, type: :component do
  before { render_inline(described_class.new) }

  it "promises the next anime in the title of the page" do
    expect(page).to have_css("h1", text: "Ton prochain anime se cache dans tes goûts.")
  end

  it "highlights what the promise is about" do
    expect(page).to have_css("h1 .na-hero__accent", text: "tes goûts")
  end

  it "leads to the swipe deck, as the main action" do
    expect(page).to have_link("Commencer à swiper", href: "/decouvrir", class: "btn-na-primary")
  end

  it "leads to the catalogue, as the secondary action" do
    expect(page).to have_link("Parcourir le catalogue", href: "/catalogue", class: "btn-na-outline")
  end

  it "says that the app is free and that swiping needs no account" do
    expect(page).to have_css(".na-hero__note", text: "Gratuit · swipe sans compte")
  end

  it "hides the Japanese kicker from assistive technologies, as it only decorates" do
    expect(page).to have_css("p[lang='ja'][aria-hidden='true']", text: "次のアニメを見つけよう")
  end
  it "decorates with three posters that assistive technologies skip" do
    expect(page).to have_css(".na-hero__showcase .na-showcase[aria-hidden='true'] .na-showcase-poster", count: 3)
  end
  context "with the covers of the anime" do
    it "shows them on the posters" do
      render_inline(described_class.new(poster_urls: { perfect_blue: "https://img.test/perfect-blue.jpg" }))

      expect(page).to have_css(".na-hero__showcase img.na-showcase-poster__image[src='https://img.test/perfect-blue.jpg']")
    end
  end
end
