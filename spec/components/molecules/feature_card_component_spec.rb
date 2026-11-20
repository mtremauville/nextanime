require "rails_helper"

RSpec.describe Molecules::FeatureCardComponent, type: :component do
  def render_card(tone: :magenta)
    render_inline(described_class.new(tag: "Watchlist", title: "Une seule liste, toutes les plateformes", tone: tone)) do
      "À voir, en cours, terminé."
    end
  end

  it "is an item of a list" do
    render_card

    expect(page).to have_css("li.na-feature")
  end

  it "labels the feature" do
    render_card

    expect(page).to have_css(".na-feature__tag", text: "Watchlist")
  end

  it "titles the feature with a heading" do
    render_card

    expect(page).to have_css("h3.na-feature__title", text: "Une seule liste, toutes les plateformes")
  end

  it "explains the feature" do
    render_card

    expect(page).to have_css(".na-feature__text", text: "À voir, en cours, terminé.")
  end

  it "takes the colour of its tone" do
    render_card(tone: :cyan)

    expect(page).to have_css("li.na-feature--cyan")
  end

  it "rejects an unknown tone" do
    expect { described_class.new(tag: "Tag", title: "Titre", tone: :green) }
      .to raise_error(ArgumentError, /Unknown tone/)
  end
end
