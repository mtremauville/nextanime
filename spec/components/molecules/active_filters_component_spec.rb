require "rails_helper"

RSpec.describe Molecules::ActiveFiltersComponent, type: :component do
  let(:chips) do
    [
      { label: "Thriller", href: "/catalogue?formats%5B%5D=movie" },
      { label: "Film", href: "/catalogue?genre_ids%5B%5D=4" }
    ]
  end

  it "renders nothing when no filter is active" do
    render_inline(described_class.new(chips: []))

    expect(page).to have_no_css(".na-active-filters")
  end

  it "is a list named after the active filters" do
    render_inline(described_class.new(chips: chips))

    expect(page).to have_css("ul.na-active-filters[aria-label='Filtres actifs']")
  end

  it "shows one chip per filter, in the order given" do
    render_inline(described_class.new(chips: chips))

    expect(page).to have_css(".na-active-filters li:nth-child(1) .na-filter-chip", text: "Thriller")
    expect(page).to have_css(".na-active-filters li:nth-child(2) .na-filter-chip", text: "Film")
  end

  it "links each chip to the page without its filter" do
    render_inline(described_class.new(chips: chips))

    expect(page).to have_link("Retirer le filtre Thriller", href: "/catalogue?formats%5B%5D=movie")
    expect(page).to have_link("Retirer le filtre Film", href: "/catalogue?genre_ids%5B%5D=4")
  end
end
