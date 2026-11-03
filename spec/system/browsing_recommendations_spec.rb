require "rails_helper"

RSpec.describe "Browsing the recommendations", type: :system, js: true do
  include Warden::Test::Helpers

  let(:thriller) { create(:genre, name: "Thriller") }
  let!(:liked) { create(:anime, title_romaji: "Liked One", title_english: nil, genres: [ thriller ], format: :tv) }

  after { Warden.test_reset! }

  context "when signed in with a like" do
    let(:user) { create(:user) }

    before do
      create(:anime, title_romaji: "Close Series", title_english: nil, genres: [ thriller ], format: :tv)
      create(:anime, title_romaji: "Close Movie", title_english: nil, genres: [ thriller ], format: :movie)
      user.create_taste_profile!.record_swipe(liked, liked: true)
      Warden.test_mode!
      login_as(user, scope: :user)
    end

    it "lists the anime that were not swiped yet" do
      visit recommendations_path

      expect(page).to have_css("[data-role='recommendation']", count: 2)
      expect(page).to have_text("Close Series")
      expect(page).to have_no_text("Liked One")
    end

    it "narrows the list to the movies and back to everything" do
      visit recommendations_path

      click_link "Films"

      expect(page).to have_css("[data-role='recommendation']", count: 1)
      expect(page).to have_text("Close Movie")
      expect(page).to have_current_path(recommendations_path(kind: "movies"))

      click_link "Tous"

      expect(page).to have_css("[data-role='recommendation']", count: 2)
    end
  end

  context "as a visitor who has not swiped" do
    it "invites to swipe and leads to the deck" do
      visit recommendations_path

      expect(page).to have_text("Swipe quelques animes")

      click_link "Commencer à swiper"

      expect(page).to have_current_path(root_path)
    end
  end
end
