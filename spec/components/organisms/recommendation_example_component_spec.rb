require "rails_helper"

RSpec.describe Organisms::RecommendationExampleComponent, type: :component do
  before { render_inline(described_class.new) }

  it "is a section named by a heading that says it is an example" do
    expect(page).to have_css("section[aria-labelledby='na-example-title'] h2#na-example-title", text: "Exemple de recommandation")
  end

  it "says visibly that it is an example" do
    expect(page).to have_css(".na-tag", text: "Exemple")
  end

  it "starts from an anime that the visitor likes" do
    expect(page).to have_css(".na-example__liked-title", text: "Death Note")
  end

  it "shows the tags of that anime" do
    tags = page.all(".na-example__liked .na-tag").map(&:text)

    expect(tags).to eq([ "Psychologique", "Thriller", "Ambiance sombre" ])
  end

  it "recommends two anime, in order" do
    titles = page.all("ul.na-example__recos > li .na-example-reco__title").map(&:text)

    expect(titles).to eq([ "Perfect Blue", "Cowboy Bebop" ])
  end

  it "gives the match of each recommendation" do
    matches = page.all(".na-example-reco .na-badge-match [aria-hidden='true']").map(&:text)

    expect(matches).to eq([ "92%", "78%" ])
  end

  it "hides the arrow from assistive technologies, as it only decorates" do
    expect(page).to have_css(".na-example__arrow[aria-hidden='true']")
  end
end
