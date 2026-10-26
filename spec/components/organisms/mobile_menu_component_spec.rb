require "rails_helper"

RSpec.describe Organisms::MobileMenuComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(items: items, countries: countries, selected_country: "FR"))
  end

  let(:items) do
    [
      { label: "Découvrir", href: "/", icon: "stars", current: false },
      { label: "Catalogue", href: "/catalogue", icon: "grid", current: true }
    ]
  end
  let(:countries) { { "FR" => "France", "BE" => "Belgique" } }

  it "renders a dialog labelled by its title" do
    expect(rendered).to have_css("dialog#mobile-menu[aria-labelledby='mobile-menu-title']")
    expect(rendered).to have_css("#mobile-menu-title", text: "Menu")
  end

  it "offers a button that closes the menu" do
    expect(rendered).to have_css("button[aria-label='Fermer le menu'][data-action*='menu#close']")
  end

  it "links every page of the navigation" do
    expect(rendered).to have_link("Découvrir", href: "/")
    expect(rendered).to have_link("Catalogue", href: "/catalogue")
  end

  it "marks the current page" do
    expect(rendered).to have_css("nav[aria-label='Navigation mobile'] a[aria-current='page']", count: 1, text: "Catalogue")
  end

  it "lists the countries in a labelled group" do
    expect(rendered).to have_css("fieldset legend", text: "Pays")
    expect(rendered).to have_field("Belgique", type: "radio", checked: false)
  end

  it "selects the given country" do
    expect(rendered).to have_field("France", type: "radio", checked: true)
  end

  it "offers the dark and light themes" do
    expect(rendered).to have_css("fieldset legend", text: "Thème")
    expect(rendered).to have_css("button[data-theme-theme-param='dark']", text: "Sombre")
    expect(rendered).to have_css("button[data-theme-theme-param='light']", text: "Clair")
  end
end
