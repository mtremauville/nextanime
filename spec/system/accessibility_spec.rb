require "rails_helper"

# Audits the pages of the app against WCAG 2.1 level AA, on a phone and on a wide screen.
RSpec.describe "Accessibility of the pages", type: :system, js: true do
  include Warden::Test::Helpers

  let(:wcag_aa) { %i[wcag2a wcag2aa wcag21a wcag21aa] }
  let(:genre) { create(:genre, name: "Thriller") }
  let!(:anime) do
    create(:anime, title_romaji: "Close Series", title_english: nil, genres: [ genre ], format: :tv,
                   description: "A dark story.", episodes: 12, cover_image_url: "https://img.test/cover.jpg")
  end
  let(:user) { create(:user) }

  public_pages = {
    "the swipe page" => "/",
    "the catalogue" => "/catalogue",
    "the sign in page" => "/users/sign_in",
    "the sign up page" => "/users/sign_up",
    "the forgotten password page" => "/users/password/new",
    "the styleguide" => "/styleguide"
  }

  member_pages = {
    "the profile" => "/profil",
    "the recommendations" => "/recos",
    "the watchlist" => "/watchlist",
    "the calendar" => "/calendrier"
  }

  before do
    3.times do |index|
      create(:anime, title_romaji: "Anime #{index}", title_english: nil, genres: [ genre ], popularity: 100 - index,
                     cover_image_url: "https://img.test/cover.jpg")
    end
    Warden.test_mode!
  end

  after { Warden.test_reset! }

  def sign_in_with_a_taste_profile
    user.create_taste_profile!.record_swipe(anime, liked: true)
    login_as(user, scope: :user)
  end

  def expect_no_violation_on(path)
    visit path
    expect(page).to have_css("main#main")
    expect(page).to be_axe_clean.according_to(*wcag_aa)
  end

  { "a phone" => [ 393, 852 ], "a wide screen" => [ 1400, 900 ] }.each do |screen, size|
    context "on #{screen}" do
      before { page.current_window.resize_to(*size) }

      public_pages.each do |name, path|
        it "has no WCAG AA violation on #{name}" do
          expect_no_violation_on(path)
        end
      end

      it "has no WCAG AA violation on the page of an anime" do
        expect_no_violation_on(anime_path(anime))
      end

      context "when signed in" do
        before { sign_in_with_a_taste_profile }

        member_pages.each do |name, path|
          it "has no WCAG AA violation on #{name}" do
            expect_no_violation_on(path)
          end
        end
      end
    end
  end

  describe "reflow on a phone" do
    before { page.current_window.resize_to(393, 852) }

    def horizontal_overflow
      page.evaluate_script("document.documentElement.scrollWidth - document.documentElement.clientWidth")
    end

    public_pages.each do |name, path|
      it "does not scroll sideways on #{name}" do
        visit path
        expect(page).to have_css("main#main")
        expect(horizontal_overflow).to be <= 0
      end
    end

    context "when signed in" do
      before { sign_in_with_a_taste_profile }

      member_pages.each do |name, path|
        it "does not scroll sideways on #{name}" do
          visit path
          expect(page).to have_css("main#main")
          expect(horizontal_overflow).to be <= 0
        end
      end
    end
  end
end
