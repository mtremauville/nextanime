require "rails_helper"

RSpec.describe "Refreshing the taste panel while swiping", type: :system, js: true do
  let(:panel) { "#taste-profile-panel" }
  let(:invitation) { "Swipe quelques animes pour dessiner ton profil." }

  before do
    thriller = create(:genre, name: "Thriller")
    create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg", genres: [ thriller ])
    visit root_path
  end

  it "starts with the invitation to swipe" do
    expect(page).to have_css(panel, text: invitation)
    expect(page).to have_no_css("#{panel} [data-role='taste']")
  end

  it "draws the genre of the anime that was liked, without reloading the page" do
    click_button "J'aime cet anime"

    expect(page).to have_css("#{panel} [data-role='taste']", text: "Thriller")
    expect(page).to have_no_text(invitation)
  end

  it "keeps the invitation when the anime is passed" do
    click_button "Passer cet anime"
    expect(page).to have_text(/(?<!\d)33 %/)

    expect(page).to have_css(panel, text: invitation)
    expect(page).to have_no_css("#{panel} [data-role='taste']")
  end
end
