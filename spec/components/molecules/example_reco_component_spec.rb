require "rails_helper"

RSpec.describe Molecules::ExampleRecoComponent, type: :component do
  def render_reco(poster: :violet)
    render_inline(described_class.new(
      title: "Perfect Blue",
      meta: "Film · 1997 · Madhouse",
      match: 92,
      reason: "Tu aimes les thrillers psychologiques à l'ambiance sombre : celui-ci partage ces thèmes.",
      poster: poster
    ))
  end

  it "is an item of a list" do
    render_reco

    expect(page).to have_css("li.na-example-reco")
  end

  it "names the anime" do
    render_reco

    expect(page).to have_css(".na-example-reco__title", text: "Perfect Blue")
  end

  it "gives its match, with the badge of the app" do
    render_reco

    expect(page).to have_css(".na-example-reco .na-badge-match [aria-hidden='true']", text: "92%")
  end

  it "says what kind of anime it is" do
    render_reco

    expect(page).to have_css(".na-example-reco__meta", text: "Film · 1997 · Madhouse")
  end

  it "says why it matches" do
    render_reco

    expect(page).to have_css(".na-example-reco__reason", text: "Tu aimes les thrillers psychologiques")
  end

  it "shows its poster, hidden from assistive technologies" do
    render_reco(poster: :cyan)

    expect(page).to have_css(".na-example-reco__poster.na-poster--cyan[aria-hidden='true']")
  end

  it "rejects an unknown poster" do
    expect { described_class.new(title: "Titre", meta: "Série", match: 50, reason: "Raison", poster: :gold) }
      .to raise_error(ArgumentError, /Unknown poster/)
  end
end
