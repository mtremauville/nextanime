require "rails_helper"

RSpec.describe Molecules::EmptyStateComponent, type: :component do
  subject(:render_state) { render_inline(described_class.new(**attributes)) }

  let(:attributes) do
    { title: "Aucune recommandation", text: "Tu as tout vu.", link_label: "Continuer à swiper", link_href: "/" }
  end

  it "renders the title as a heading" do
    render_state

    expect(page).to have_css("h2", text: "Aucune recommandation")
  end

  it "renders the text" do
    render_state

    expect(page).to have_css("p", text: "Tu as tout vu.")
  end

  it "renders the link as a primary button by default" do
    render_state

    expect(page).to have_link("Continuer à swiper", href: "/", class: "btn-na-primary")
  end

  it "renders the link as an outline button when asked" do
    attributes[:link_variant] = :outline
    render_state

    expect(page).to have_link("Continuer à swiper", class: "btn-na-outline")
  end
end
