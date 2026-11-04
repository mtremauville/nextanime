require "rails_helper"

RSpec.describe Molecules::SearchFieldComponent, type: :component do
  def render_field(value: nil)
    render_inline(
      described_class.new(
        action: "/catalogue",
        label: "Rechercher un anime",
        placeholder: "Rechercher un titre, un studio…",
        value: value
      )
    )
  end

  it "is a search form sent with a GET to the given address" do
    render_field

    expect(page).to have_css("form[role='search'][method='get'][action='/catalogue']")
  end

  it "labels the field for a screen reader" do
    render_field

    expect(page).to have_css("label[for='search-q']", text: "Rechercher un anime")
    expect(page).to have_field("Rechercher un anime", type: "search")
  end

  it "sends the text under the name q" do
    render_field

    expect(page).to have_css("input#search-q[type='search'][name='q']")
  end

  it "suggests what can be searched" do
    render_field

    expect(page).to have_field("Rechercher un anime", placeholder: "Rechercher un titre, un studio…")
  end

  it "is empty by default" do
    render_field

    expect(page.find_field("Rechercher un anime").value.to_s).to eq("")
  end

  it "shows the text that was searched" do
    render_field(value: "monster")

    expect(page).to have_field("Rechercher un anime", with: "monster")
  end

  it "asks a mobile keyboard for a search key" do
    render_field

    expect(page).to have_css("input[enterkeyhint='search']")
  end

  it "hides its icon from assistive technologies" do
    render_field

    expect(page).to have_css(".na-search__icon[aria-hidden='true']")
  end

  it "sends nothing but the text" do
    render_field

    expect(page).to have_no_css("input[type='hidden']")
  end
end
