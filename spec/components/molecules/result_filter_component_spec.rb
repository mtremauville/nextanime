require "rails_helper"

RSpec.describe Molecules::ResultFilterComponent, type: :component do
  subject(:render_filter) do
    render_inline(described_class.new(label: "Filtrer par format", choices: choices, summary: "Trié par match · 8 résultats"))
  end

  let(:choices) do
    [
      { label: "Tous", href: "/recos", current: true },
      { label: "Séries", href: "/recos?kind=series", current: false },
      { label: "Films", href: "/recos?kind=movies", current: false }
    ]
  end

  it "groups the choices under an accessible label" do
    render_filter

    expect(page).to have_css("[role='group'][aria-label='Filtrer par format']")
  end

  it "renders one link per choice" do
    render_filter

    expect(page).to have_css("a", count: 3)
    expect(page).to have_link("Séries", href: "/recos?kind=series")
    expect(page).to have_link("Films", href: "/recos?kind=movies")
  end

  it "marks only the current choice" do
    render_filter

    expect(page).to have_css("a[aria-current='true']", count: 1, text: "Tous")
    expect(page).to have_no_css("a[aria-current]", text: "Séries")
  end

  it "renders the summary" do
    render_filter

    expect(page).to have_css("p", text: "Trié par match · 8 résultats")
  end
end
