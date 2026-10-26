require "rails_helper"

RSpec.describe Organisms::MainNavigationComponent, type: :component do
  subject(:rendered) { render_inline(described_class.new(current_path: current_path)) }

  let(:current_path) { "/catalogue" }
  let(:labels) { %w[Découvrir Catalogue Recos Watchlist Calendrier] }

  it "links the brand to the home page" do
    expect(rendered).to have_css("header a[href='/']", text: "NextAnime")
  end

  it "renders the five pages in the desktop navigation" do
    labels.each do |label|
      expect(rendered).to have_css("nav[aria-label='Navigation principale'] a", text: label)
    end
  end

  it "renders the five pages in the mobile tab bar" do
    labels.each do |label|
      expect(rendered).to have_css("nav[aria-label='Onglets'] a", text: label)
    end
  end

  it "offers a country selector" do
    expect(rendered).to have_select("Pays")
  end

  it "offers a theme toggle" do
    expect(rendered).to have_css("button[data-action*='theme#toggle']")
  end
  it "shows both theme icons and lets the stylesheet pick the right one" do
    expect(rendered).to have_css('button .bi-sun.na-theme-toggle__sun[aria-hidden="true"]')
    expect(rendered).to have_css('button .bi-moon-stars.na-theme-toggle__moon[aria-hidden="true"]')
  end

  describe "current page" do
    it "marks only the current page in each navigation" do
      expect(rendered).to have_css("nav[aria-label='Navigation principale'] a[aria-current='page']", count: 1, text: "Catalogue")
      expect(rendered).to have_css("nav[aria-label='Onglets'] a[aria-current='page']", count: 1, text: "Catalogue")
    end

    context "when on a sub-page of a section" do
      let(:current_path) { "/catalogue/42" }

      it "keeps the section active" do
        expect(rendered).to have_css("nav[aria-label='Onglets'] a[aria-current='page']", text: "Catalogue")
      end
    end

    context "when on the home page" do
      let(:current_path) { "/" }

      it "activates only the Découvrir tab" do
        expect(rendered).to have_css("nav[aria-label='Onglets'] a[aria-current='page']", count: 1, text: "Découvrir")
      end
    end

    context "when on an unknown page" do
      let(:current_path) { "/styleguide" }

      it "marks no tab as current" do
        expect(rendered).to have_no_css("a[aria-current='page']")
      end
    end
  end
end
