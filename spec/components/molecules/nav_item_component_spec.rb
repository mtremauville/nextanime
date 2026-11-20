require "rails_helper"

RSpec.describe Molecules::NavItemComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(label: "Catalogue", href: "/catalogue", icon: "grid", current: current))
  end

  let(:current) { false }

  it "renders a link to the target page" do
    expect(rendered).to have_link("Catalogue", href: "/catalogue")
  end

  it "hides the icon from assistive technologies" do
    expect(rendered).to have_css("a i.bi.bi-grid[aria-hidden='true']")
  end

  context "when the page is not the current one" do
    it "does not set aria-current" do
      expect(rendered).to have_no_css("a[aria-current]")
    end

    it "does not use the active class" do
      expect(rendered).to have_no_css("a.na-nav__link--active")
    end
  end

  context "when the page is the current one" do
    let(:current) { true }

    it "marks the link as the current page" do
      expect(rendered).to have_css("a[aria-current='page']")
    end

    it "uses the active class" do
      expect(rendered).to have_css("a.na-nav__link--active")
    end
  end
end
