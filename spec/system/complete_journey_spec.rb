require "rails_helper"

# The whole journey of a new visitor, from the first swipe to the watchlist, in one browser session.
# Each step is tested on its own elsewhere: this spec only checks that the steps work together.
RSpec.describe "The journey of a new visitor", type: :system, js: true do
  let(:email) { "journey@example.com" }
  let(:password) { "a-long-password-123" }
  let(:visible_slot) { ".na-swipe-deck__slot:not([hidden])" }
  let(:thriller) { create(:genre, name: "Thriller") }

  before do
    %w[One Two Three].each do |name|
      create(:anime, title_romaji: "Journey #{name}", title_english: nil, genres: [ thriller ],
                     format: :tv, episodes: 12, cover_image_url: "https://img.test/cover.jpg")
    end
  end

  # The guard keeps "0 %" from matching inside "100 %".
  def have_percent(value)
    have_text(/(?<!\d)#{value} %/)
  end

  def swipe_as_a_guest
    visit root_path
    swiped_id = find(visible_slot)["data-anime-id"].to_i
    click_button "J'aime cet anime"
    expect(page).to have_percent(33)
    swiped_id
  end

  def sign_up
    visit new_user_registration_path
    fill_in "user[email]", with: email
    fill_in "user[password]", with: password
    fill_in "user[password_confirmation]", with: password
    check "user[privacy_policy]", allow_label_click: true
    click_button "Créer mon compte"
    expect(page).to have_current_path(root_path)
  end

  def open_a_recommendation_other_than(swiped_id)
    visit recommendations_path
    expect(page).to have_css("[data-role='recommendation']", count: 2)

    anime = Anime.where.not(id: swiped_id).order(:id).first
    within("[data-role='recommendation']", text: anime.display_title) { click_link anime.display_title }
    expect(page).to have_css("h1", text: anime.display_title)
    anime
  end

  it "goes from a first swipe to a watched episode, then back to an empty watchlist" do
    swiped_id = swipe_as_a_guest
    sign_up
    title = open_a_recommendation_other_than(swiped_id).display_title

    click_button "+ Ajouter à ma watchlist"
    expect(page).to have_text("Ajouté à ta watchlist.")
    click_link "Dans ma watchlist"
    expect(page).to have_css(".na-watch-row", text: title)

    find("button[aria-label='Un épisode de plus pour #{title}']").click
    expect(page).to have_text(/ép\.\s*1\b/i)

    find("button[aria-label='Retirer #{title} de ta watchlist']").click
    within("dialog[open]") { click_button "Retirer" }
    expect(page).to have_text("#{title} a été retiré de ta watchlist.")
    expect(page).to have_text("Ta watchlist est vide")
  end
end
