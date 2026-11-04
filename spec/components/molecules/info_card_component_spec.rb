require "rails_helper"

RSpec.describe Molecules::InfoCardComponent, type: :component do
  let(:rows) { [ [ "Format", "Série" ], [ "Studio", "MAPPA" ] ] }

  it "is a region named by its title" do
    render_inline(described_class.new(rows: rows))

    expect(page).to have_css("aside[aria-labelledby='anime-info-title']")
    expect(page).to have_css("h2#anime-info-title", text: "Informations")
  end

  it "lists each label with its value" do
    render_inline(described_class.new(rows: rows))

    expect(page).to have_css("dt", count: 2)
    expect(page).to have_css("dt", text: "Format")
    expect(page).to have_css("dd", text: "Série")
    expect(page).to have_css("dt", text: "Studio")
    expect(page).to have_css("dd", text: "MAPPA")
  end

  it "shows nothing without rows" do
    render_inline(described_class.new(rows: []))

    expect(page).to have_no_css("aside")
  end
end
