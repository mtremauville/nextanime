require "rails_helper"

RSpec.describe "Keeping the guest swipes after sign up", type: :system, js: true do
  let(:email) { "new.user@example.com" }
  let(:password) { "a-long-password-123" }
  let(:visible_slot) { ".na-swipe-deck__slot:not([hidden])" }

  before do
    create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg")
  end

  # The progress is shown in capitals by the stylesheet, and the browser returns the rendered text.
  def have_progress(position, total)
    have_text(%r{anime #{position} / #{total}}i)
  end

  def sign_up
    visit new_user_registration_path
    fill_in "user[email]", with: email
    fill_in "user[password]", with: password
    fill_in "user[password_confirmation]", with: password
    check "user[privacy_policy]", allow_label_click: true
    click_button "Créer mon compte"
  end

  it "does not offer again the anime swiped as a guest" do
    visit root_path
    swiped_id = find(visible_slot)["data-anime-id"].to_i
    click_button "J'aime cet anime"
    expect(page).to have_progress(2, 3)

    sign_up

    expect(page).to have_current_path(root_path)
    expect(page).to have_progress(1, 2)
    expect(page).to have_no_css("[data-anime-id='#{swiped_id}']", visible: :all)
  end

  it "stores the guest swipes on the new account" do
    visit root_path
    swiped_id = find(visible_slot)["data-anime-id"].to_i
    click_button "J'aime cet anime"
    expect(page).to have_progress(2, 3)

    sign_up
    expect(page).to have_current_path(root_path)

    expect(User.find_by!(email: email).taste_profile.swiped_anime_ids).to eq([ swiped_id ])
  end
end
