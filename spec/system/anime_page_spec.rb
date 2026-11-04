require "rails_helper"

RSpec.describe "Opening the page of an anime", type: :system, js: true do
  include Warden::Test::Helpers

  let(:thriller) { create(:genre, name: "Thriller") }
  let!(:liked) { create(:anime, title_romaji: "Liked One", title_english: nil, genres: [ thriller ], format: :tv) }
  let(:user) { create(:user) }

  before do
    create(:anime, title_romaji: "Close Series", title_english: nil, genres: [ thriller ], format: :tv,
                   description: "A dark story.", episodes: 12)
    user.create_taste_profile!.record_swipe(liked, liked: true)
    Warden.test_mode!
    login_as(user, scope: :user)
  end

  after { Warden.test_reset! }

  it "opens the page of an anime from its card in the recommendations" do
    visit recommendations_path

    click_link "Close Series"

    expect(page).to have_css("h1", text: "Close Series")
    expect(page).to have_text("A dark story.")
    expect(page).to have_css(".na-match-panel__text", text: "Parce que tu aimes Thriller.")
  end

  it "goes back to the recommendations" do
    visit recommendations_path
    click_link "Close Series"

    click_link "← Retour aux recommandations"

    expect(page).to have_current_path(recommendations_path)
    expect(page).to have_css("[data-role='recommendation']", count: 1)
  end
end
