require "rails_helper"

RSpec.describe Organisms::TasteProfileCardComponent, type: :component do
  let(:genres) { [ [ "Thriller", 0.85 ], [ "Drame", 0.4 ] ] }
  let(:tags) { [ [ "Mystery", 0.5 ], [ "Tragédie", 0.3 ] ] }
  let(:swipes_count) { 24 }

  def render_card
    render_inline(described_class.new(genres: genres, tags: tags, swipes_count: swipes_count, swipe_href: "/", reset_href: "/taste_profile/reset"))
  end

  it "is a region named by its heading" do
    render_card

    expect(page).to have_css("section[aria-labelledby=taste-card-title] h2#taste-card-title", text: "Mon profil de goûts")
  end

  it "tells how many swipes it is computed from" do
    render_card

    expect(page).to have_text("Calculé à partir de tes 24 swipes.")
  end

  context "with a single swipe" do
    let(:swipes_count) { 1 }

    it "speaks of one swipe in the singular" do
      render_card

      expect(page).to have_text("Calculé à partir de ton swipe.")
    end
  end

  it "lists each genre with its percentage" do
    render_card

    expect(page).to have_css("[data-list=genres] li", text: "Thriller")
    expect(page).to have_css("[data-list=genres] li", text: "85%")
    expect(page).to have_css("[data-list=genres] li", text: "Drame")
    expect(page).to have_css("[data-list=genres] li", text: "40%")
  end

  it "draws a labelled bar for each genre" do
    render_card

    expect(page).to have_css("[role=progressbar][aria-label=Thriller][aria-valuenow='85']")
    expect(page).to have_css("[role=progressbar][aria-label=Drame][aria-valuenow='40']")
  end

  it "alternates the tone of the bars" do
    render_card

    expect(page).to have_css(".na-meter__fill--cyan", count: 1)
  end

  it "lists the tags as pills" do
    render_card

    expect(page).to have_css("[data-list=tags] li .na-tag", count: 2)
    expect(page).to have_css("[data-list=tags] li", text: "Mystery")
  end

  it "alternates the tone of the tags" do
    render_card

    expect(page).to have_css(".na-tag--cyan", count: 1)
  end

  it "offers to keep swiping" do
    render_card

    expect(page).to have_css("a.btn-na-primary[href='/']", text: "Continuer à swiper")
  end

  it "offers to reset the profile after a confirmation" do
    render_card

    expect(page).to have_css("button", text: "Réinitialiser mon profil")
    expect(page).to have_css("dialog#reset-profile form[action='/taste_profile/reset'] input[name=_method][value=delete]", visible: :all)
  end

  context "when no genre stands out" do
    let(:genres) { [] }

    it "shows the tags only" do
      render_card

      expect(page).to have_no_css("[data-list=genres]")
      expect(page).to have_css("[data-list=tags]")
    end
  end

  context "when no tag stands out" do
    let(:tags) { [] }

    it "shows the genres only" do
      render_card

      expect(page).to have_css("[data-list=genres]")
      expect(page).to have_no_css("[data-list=tags]")
    end
  end

  context "without any taste yet" do
    let(:genres) { [] }
    let(:tags) { [] }
    let(:swipes_count) { 0 }

    it "invites to swipe instead of listing anything" do
      render_card

      expect(page).to have_text("Swipe quelques anime pour que ton profil de goûts se dessine.")
      expect(page).to have_no_text("Calculé à partir")
      expect(page).to have_no_css("[data-list]")
    end
  end
end
