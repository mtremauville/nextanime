require "rails_helper"

RSpec.describe Organisms::CatalogueSkeletonComponent, type: :component do
  before { render_inline(described_class.new) }

  it "lays out its cards with the grid of the catalogue" do
    expect(page).to have_css("ul.na-catalogue-grid.na-catalogue-skeleton")
  end

  it "shows as many cards as a page of the catalogue" do
    expect(page).to have_css("li.na-catalogue-grid__item .na-skeleton-card", count: 12)
  end

  it "is hidden from assistive technologies" do
    expect(page).to have_css("ul.na-catalogue-skeleton[aria-hidden='true']")
  end
end
