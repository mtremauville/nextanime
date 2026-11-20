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
    expect(page).to have_link("Découvrir mes recommandations", href: "/decouvrir", class: "btn-na-primary")
  end

  it "leads to the calendar, as the secondary action" do
    expect(page).to have_link("Voir le calendrier", href: "/calendrier", class: "btn-na-outline")
  end

  it "says that the app is free and needs no sign up" do
    expect(page).to have_css(".na-hero__note", text: "Gratuit · sans inscription")
  end

  it "hides the Japanese kicker from assistive technologies, as it only decorates" do
    expect(page).to have_css("p[lang='ja'][aria-hidden='true']", text: "次のアニメを見つけよう")
  end
end
