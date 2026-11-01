require "rails_helper"

RSpec.describe "Resetting the taste profile", type: :system, js: true do
  before do
    create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg")
    visit root_path
  end

  # The progress is shown in capitals by the stylesheet, and the browser returns the rendered text.
  def have_progress(position, total)
    have_text(%r{anime #{position} / #{total}}i)
  end

  def swipe_once
    click_button "J'aime cet anime"
    expect(page).to have_progress(2, 3)
  end

  def open_confirmation
    click_button "Réinitialiser mon profil"
    expect(page).to have_css("dialog#reset-profile[open]")
  end

  it "gives the whole deck back after the confirmation" do
    swipe_once
    open_confirmation

    within("dialog#reset-profile") { click_button "Réinitialiser" }

    expect(page).to have_text("Ton profil de goûts a été réinitialisé.")
    expect(page).to have_progress(1, 3)
  end

  it "keeps the swipes when the visitor cancels" do
    swipe_once
    open_confirmation

    within("dialog#reset-profile") { click_button "Annuler" }
    visit root_path

    expect(page).to have_progress(1, 2)
  end
end
