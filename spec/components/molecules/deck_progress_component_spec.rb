require "rails_helper"

RSpec.describe Molecules::DeckProgressComponent, type: :component do
  subject(:render_progress) { render_inline(described_class.new(completed: completed, total: 20)) }

  let(:completed) { 7 }

  it "names the session" do
    render_progress

    expect(page).to have_text("Ta session")
  end

  it "shows the share of the session already swiped" do
    render_progress

    expect(page).to have_text("35 %")
  end

  it "does not count the cards left" do
    render_progress

    expect(page).to have_no_text("Plus que")
    expect(page).to have_no_text("Anime")
  end

  it "fills the bar in proportion to the cards swiped" do
    render_progress

    expect(page).to have_css("[role=progressbar][aria-valuenow='35']")
  end

  it "rounds the percentage to the nearest whole number" do
    render_inline(described_class.new(completed: 2, total: 3))

    expect(page).to have_text("67 %")
    expect(page).to have_css("[role=progressbar][aria-valuenow='67']")
  end

  context "when nothing has been swiped yet" do
    let(:completed) { 0 }

    it "starts at 0 %" do
      render_progress

      expect(page).to have_text("0 %")
      expect(page).to have_css("[role=progressbar][aria-valuenow='0']")
    end
  end

  context "when every card has been swiped" do
    let(:completed) { 20 }

    it "reaches 100 %" do
      render_progress

      expect(page).to have_text("100 %")
    end
  end

  it "refuses a number of swiped cards outside the session" do
    expect { described_class.new(completed: -1, total: 20) }.to raise_error(ArgumentError, /Completed/)
    expect { described_class.new(completed: 21, total: 20) }.to raise_error(ArgumentError, /Completed/)
  end

  it "refuses an empty session" do
    expect { described_class.new(completed: 0, total: 0) }.to raise_error(ArgumentError, /Completed/)
  end

  it "can be replaced by a Turbo Stream through its id" do
    render_progress

    expect(page).to have_css("div#deck-progress.na-deck-progress")
  end
end
