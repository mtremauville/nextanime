require "rails_helper"

RSpec.describe Atoms::FilterChipComponent, type: :component do
  before { render_inline(described_class.new(label: "Thriller", remove_href: "/catalogue?q=a")) }

  it "shows the label" do
    expect(page).to have_css(".na-filter-chip", text: "Thriller")
  end

  it "links the removal to the given address, under a name that says what it removes" do
    expect(page).to have_link("Retirer le filtre Thriller", href: "/catalogue?q=a")
  end

  it "hides the cross from screen readers, the link already has a name" do
    expect(page).to have_css("a.na-filter-chip__remove span[aria-hidden='true']", text: "×")
  end
end
