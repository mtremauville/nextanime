require "rails_helper"

RSpec.describe Organisms::DataCardComponent, type: :component do
  subject(:card) do
    render_inline(described_class.new(export_href: "/profil/export"))
    page
  end

  it "is a section named by its heading" do
    expect(card).to have_css("section.na-data-card[aria-labelledby='data-card-title']")
  end

  it "introduces the card with a heading" do
    expect(card).to have_css("h2#data-card-title", text: "Mes données")
  end

  it "reminds that the data can be taken away at any time" do
    expect(card).to have_text("Tu peux récupérer tes données à tout moment.")
  end

  it "says what the file holds" do
    expect(card).to have_text("compte, tes swipes et ta watchlist")
  end

  it "offers the export as a link to the export" do
    expect(card).to have_link("Exporter mes données", href: "/profil/export")
  end

  it "bypasses Turbo so that the browser downloads the file" do
    expect(card).to have_css("a[href='/profil/export'][data-turbo='false']")
  end
end
