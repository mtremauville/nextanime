require "rails_helper"

RSpec.describe "Keeping the guest swipes after sign in", type: :system, js: true do
  let(:password) { "a-long-password-123" }
  let!(:account) { create(:user, password: password, password_confirmation: password) }
  let(:visible_slot) { ".na-swipe-deck__slot:not([hidden])" }

  before do
    create_list(:anime, 4, cover_image_url: "https://img.test/cover.jpg")
  end

  # The progress is shown in capitals by the stylesheet, and the browser returns the rendered text.
  def have_progress(position, total)
    have_text(%r{anime #{position} / #{total}}i)
  end

  def swipe_as_a_guest
    visit root_path
    guest_swiped_id = find(visible_slot)["data-anime-id"].to_i
    click_button "J'aime cet anime"
    expect(page).to have_progress(2, 4)
    guest_swiped_id
  end

  def give_the_account_a_swipe_on_another_anime(guest_swiped_id)
    known_anime = Anime.where.not(id: guest_swiped_id).first
    create(:taste_profile, :with_user, user: account).record_swipe(known_anime, liked: false)
    known_anime.id
  end

  def sign_in
    visit new_user_session_path
    fill_in "user[email]", with: account.email
    fill_in "user[password]", with: password
    click_button "Se connecter"
  end

  it "does not offer again the anime swiped as a guest nor the ones of the account" do
    guest_swiped_id = swipe_as_a_guest
    account_swiped_id = give_the_account_a_swipe_on_another_anime(guest_swiped_id)

    sign_in

    expect(page).to have_current_path(root_path)
    expect(page).to have_progress(1, 2)
    expect(page).to have_no_css("[data-anime-id='#{guest_swiped_id}']", visible: :all)
    expect(page).to have_no_css("[data-anime-id='#{account_swiped_id}']", visible: :all)
  end

  it "stores the guest swipes in the profile of the account" do
    guest_swiped_id = swipe_as_a_guest
    account_swiped_id = give_the_account_a_swipe_on_another_anime(guest_swiped_id)

    sign_in
    expect(page).to have_current_path(root_path)

    expect(account.reload.taste_profile.swiped_anime_ids).to contain_exactly(guest_swiped_id, account_swiped_id)
  end
end
