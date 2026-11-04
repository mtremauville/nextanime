require "rails_helper"

RSpec.describe Molecules::FilterGroupComponent, type: :component do
  let(:options) { [ [ "tv", "Série" ], [ "movie", "Film" ], [ "ova", "OVA" ] ] }

  def render_group(selected: [], **given)
    render_inline(described_class.new(name: "formats", legend: "Format", options: options, selected: selected, **given))
  end

  it "groups the choices in a fieldset named by its legend" do
    render_group

    expect(page).to have_css("fieldset legend", text: "Format")
  end

  it "offers one checkbox per choice, with its label" do
    render_group

    expect(page).to have_field("Série", type: "checkbox", with: "tv")
    expect(page).to have_field("Film", type: "checkbox", with: "movie")
    expect(page).to have_field("OVA", type: "checkbox", with: "ova")
  end

  it "sends the choices as a list under the name of the group" do
    render_group

    expect(page).to have_css("input[type='checkbox'][name='formats[]']", count: 3)
  end

  it "adds no hidden field, so that nothing is sent when nothing is checked" do
    render_group

    expect(page).to have_no_css("input[type='hidden']", visible: :all)
  end

  it "checks the selected choices only" do
    render_group(selected: %w[movie])

    expect(page).to have_checked_field("Film")
    expect(page).to have_unchecked_field("Série")
    expect(page).to have_unchecked_field("OVA")
  end

  it "checks a choice whatever the type of the selected value" do
    render_inline(described_class.new(name: "genre_ids", legend: "Genres", options: [ [ 3, "Action" ], [ 5, "Comédie" ] ], selected: [ 5 ]))

    expect(page).to have_checked_field("Comédie")
    expect(page).to have_unchecked_field("Action")
  end

  it "gives each checkbox its own id, tied to its label" do
    render_group

    ids = page.all("input[type='checkbox']").map { |input| input[:id] }

    expect(ids.uniq.size).to eq(3)
    expect(page).to have_css("label[for='#{ids.first}']", text: "Série")
  end

  it "renders nothing when there is no choice" do
    render_inline(described_class.new(name: "genre_ids", legend: "Genres", options: [], selected: []))

    expect(page).to have_no_css("fieldset")
  end
end
