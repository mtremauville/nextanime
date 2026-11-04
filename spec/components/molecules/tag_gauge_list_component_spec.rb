require "rails_helper"

RSpec.describe Molecules::TagGaugeListComponent, type: :component do
  let(:tags) do
    [
      AnimeDetails::RankedTag.new(name: "Démons", rank: 92),
      AnimeDetails::RankedTag.new(name: "Humour noir", rank: 55)
    ]
  end

  before { render_inline(described_class.new(tags: tags)) }

  it "lists one line per tag" do
    expect(page).to have_css("li[data-role='tag']", count: 2)
    expect(page).to have_css("li[data-role='tag']", text: "Démons")
    expect(page).to have_css("li[data-role='tag']", text: "Humour noir")
  end

  it "shows the rank of each tag" do
    expect(page).to have_css("li[data-role='tag']", text: "92 %")
    expect(page).to have_css("li[data-role='tag']", text: "55 %")
  end

  it "draws a gauge for each tag" do
    expect(page).to have_css("[role='progressbar'][aria-valuenow='92'][aria-label='Démons']")
    expect(page).to have_css("[role='progressbar'][aria-valuenow='55'][aria-label='Humour noir']")
  end

  it "alternates magenta and cyan" do
    expect(page.find("li[data-role='tag']", text: "Démons")).to have_no_css(".na-meter__fill--cyan")
    expect(page.find("li[data-role='tag']", text: "Humour noir")).to have_css(".na-meter__fill--cyan")
  end

  it "shows nothing without tags" do
    render_inline(described_class.new(tags: []))

    expect(page).to have_no_css("li")
  end
end
