require "rails_helper"

RSpec.describe Molecules::SelectFieldComponent, type: :component do
  let(:options) { [ [ "winter", "Hiver" ], [ "spring", "Printemps" ], [ "fall", "Automne" ] ] }

  def render_select(selected: nil)
    render_inline(described_class.new(name: "season", label: "Saison", options: options, selected: selected, blank: "Toutes les saisons"))
  end

  it "ties its label to the list" do
    render_select

    expect(page).to have_select("Saison")
  end

  it "sends its choice under its name" do
    render_select

    expect(page).to have_css("select[name='season']")
  end

  it "starts with the empty choice, then lists the choices in order" do
    render_select

    expect(page.all("option").map(&:text)).to eq([ "Toutes les saisons", "Hiver", "Printemps", "Automne" ])
  end

  it "gives the empty choice an empty value, so that nothing is filtered" do
    render_select

    expect(page.first("option")[:value]).to eq("")
  end

  it "marks no choice when nothing is selected, so that the browser shows the empty one first" do
    render_select

    expect(page).to have_no_css("option[selected]")
  end

  it "selects the chosen value" do
    render_select(selected: "fall")

    expect(page).to have_select("Saison", selected: "Automne")
  end
end
