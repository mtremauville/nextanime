require "rails_helper"

RSpec.describe "Resetting the taste profile", type: :system, js: true do
  include Warden::Test::Helpers

  let(:user) { create(:user) }

  before do
    Warden.test_mode!
    login_as(user, scope: :user)
    create_list(:swipe, 2, taste_profile: create(:taste_profile, :with_user, user: user), liked: true)
    visit profile_path
  end

  after { Warden.test_reset! }

  def open_confirmation
    click_button "Réinitialiser mon profil"
    expect(page).to have_css("dialog#reset-profile[open]")
  end

  it "empties the taste profile after the confirmation" do
    expect(page).to have_css("[data-stat=swipes]", exact_text: "2")
    open_confirmation

    within("dialog#reset-profile") { click_button "Réinitialiser" }

    expect(page).to have_text("Ton profil de goûts a été réinitialisé.")
    visit profile_path
    expect(page).to have_css("[data-stat=swipes]", exact_text: "0")
  end

  it "keeps the swipes when the user cancels" do
    open_confirmation

    within("dialog#reset-profile") { click_button "Annuler" }
    visit profile_path

    expect(page).to have_css("[data-stat=swipes]", exact_text: "2")
  end
end
