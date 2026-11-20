require "rails_helper"

RSpec.describe Molecules::FiltersTriggerComponent, type: :component do
  def render_trigger(count:)
    render_inline(described_class.new(count: count, controls: "filters-sheet"))
  end

  it "is a button that opens the dialog it points to" do
    render_trigger(count: 0)

    expect(page).to have_css("button[type='button'][aria-haspopup='dialog'][aria-controls='filters-sheet']")
  end

  it "is named after the filters when none is active" do
    render_trigger(count: 0)

    expect(page).to have_button("Filtres", exact: true)
    expect(page).to have_no_css(".na-filters-trigger__count")
  end

  it "tells how many filters are active" do
    render_trigger(count: 3)

    expect(page).to have_css("button .na-filters-trigger__count", text: "(3)")
    expect(page).to have_button("Filtres (3)")
  end

  it "hides its icon from screen readers" do
    render_trigger(count: 0)

    expect(page).to have_css("button i.bi[aria-hidden='true']")
  end
end
