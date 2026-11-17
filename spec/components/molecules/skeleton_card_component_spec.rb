require "rails_helper"

RSpec.describe Molecules::SkeletonCardComponent, type: :component do
  before { render_inline(described_class.new) }

  it "has the shape of a poster card, so the page does not jump when the results arrive" do
    expect(page).to have_css("article.na-card.na-poster-card.na-skeleton-card .na-poster-card__frame .na-skeleton")
  end

  it "holds two bars for the title and the details" do
    expect(page).to have_css(".na-skeleton-card .na-skeleton--title")
    expect(page).to have_css(".na-skeleton-card .na-skeleton--meta")
  end

  it "is hidden from assistive technologies, as it holds nothing to read" do
    expect(page).to have_css("article.na-skeleton-card[aria-hidden='true']")
  end

  it "holds no link and no heading" do
    expect(page).to have_no_link
    expect(page).to have_no_css("h1, h2, h3, h4, h5, h6")
  end
end
