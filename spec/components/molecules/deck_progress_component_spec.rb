require "rails_helper"

RSpec.describe Molecules::DeckProgressComponent, type: :component do
  subject(:render_progress) { render_inline(described_class.new(position: position, total: 24)) }

  let(:position) { 7 }

  it "shows the position in the deck" do
    render_progress

    expect(page).to have_text("Anime 7 / 24")
  end

  it "tells how many anime are left" do
    render_progress

    expect(page).to have_text("Plus que 17")
  end

  it "fills the bar in proportion to the position" do
    render_inline(described_class.new(position: 6, total: 24))

    expect(page).to have_css("[role=progressbar][aria-valuenow='25']")
  end

  context "on the last anime" do
    let(:position) { 24 }

    it "says it is the last one instead of counting down" do
      render_progress

      expect(page).to have_text("Dernier anime")
      expect(page).to have_no_text("Plus que")
    end
  end

  it "refuses a position outside the deck" do
    expect { described_class.new(position: 0, total: 24) }.to raise_error(ArgumentError, /Position/)
  end
end
