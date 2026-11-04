require "rails_helper"

RSpec.describe Molecules::LoadMoreComponent, type: :component do
  def render_load_more(shown:, total:, next_url: "/catalogue?page=2")
    render_inline(described_class.new(shown: shown, total: total, next_url: next_url))
  end

  it "renders nothing for an empty catalogue" do
    render_load_more(shown: 0, total: 0, next_url: nil)

    expect(page).to have_no_css("##{described_class::DOM_ID}")
  end

  it "can be found by its id to be replaced by a turbo stream" do
    render_load_more(shown: 12, total: 84)

    expect(page).to have_css("div##{described_class::DOM_ID}")
  end

  it "tells how many anime are shown out of the total" do
    render_load_more(shown: 12, total: 84)

    expect(page).to have_css("[data-role='progress']", text: "12 sur 84")
  end

  it "shows the progress as a progress bar" do
    render_load_more(shown: 12, total: 84)

    expect(page).to have_css(
      "[role='progressbar'][aria-valuenow='14'][aria-label='Anime affichés']"
    )
  end

  it "offers to load more through a turbo stream" do
    render_load_more(shown: 12, total: 84)

    expect(page).to have_link("Voir plus", href: "/catalogue?page=2")
    expect(page).to have_css("a[data-turbo-stream='true']", text: "Voir plus")
  end

  it "offers nothing more once everything is shown" do
    render_load_more(shown: 84, total: 84, next_url: nil)

    expect(page).to have_no_link("Voir plus")
    expect(page).to have_css("[data-role='progress']", text: "84 sur 84")
  end
end
