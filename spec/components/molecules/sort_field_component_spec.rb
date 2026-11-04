require "rails_helper"

RSpec.describe Molecules::SortFieldComponent, type: :component do
  def render_sort(selected: "popularity", offer_match: true, hidden: {})
    render_inline(described_class.new(action: "/catalogue", selected: selected, offer_match: offer_match, hidden: hidden))
  end

  it "sends the sort with a GET to the given address" do
    render_sort

    expect(page).to have_css("form[method='get'][action='/catalogue']")
  end

  it "labels the list" do
    render_sort

    expect(page).to have_select("Trier par")
    expect(page).to have_css("select[name='sort']")
  end

  it "offers the match, the popularity, the score, the date and the title, in that order" do
    render_sort

    expect(page.all("select option").map(&:text)).to eq([ "Meilleur match", "Popularité", "Note", "Plus récents", "Titre A–Z" ])
    expect(page.all("select option").map { |option| option[:value] }).to eq(CatalogueQuery::SORTS)
  end

  it "leaves out the match when it cannot be told" do
    render_sort(offer_match: false)

    expect(page.all("select option").map(&:text)).to eq([ "Popularité", "Note", "Plus récents", "Titre A–Z" ])
  end

  it "selects the sort that is under way" do
    render_sort(selected: "score")

    expect(page).to have_select("Trier par", selected: "Note")
  end

  it "carries the rest of the params, so that sorting does not erase them" do
    render_sort(hidden: { q: "monster", formats: %w[tv] })

    expect(page).to have_css("input[type='hidden'][name='q'][value='monster']", visible: :all)
    expect(page).to have_css("input[type='hidden'][name='formats[]'][value='tv']", visible: :all)
  end

  it "sends the form whenever the choice changes" do
    render_sort

    expect(page).to have_css("form[data-controller='auto-submit'][data-action='change->auto-submit#submit']")
  end

  it "keeps a button for visitors without scripts" do
    render_sort

    expect(page).to have_css("input[type='submit'].na-sort__apply")
  end
end
