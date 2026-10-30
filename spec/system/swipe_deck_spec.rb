require "rails_helper"

RSpec.describe "Swiping the deck", type: :system, js: true do
  let(:visible_slot) { ".na-swipe-deck__slot:not([hidden])" }

  before do
    create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg")
    visit root_path
  end

  # The progress is shown in capitals by the stylesheet, and the browser returns the rendered text.
  def have_progress(position)
    have_text(%r{anime #{position} / 3}i)
  end

  def displayed_anime_id
    find(visible_slot)["data-anime-id"].to_i
  end

  it "starts on the first card" do
    expect(page).to have_progress(1)
    expect(page).to have_css(visible_slot, count: 1)
  end

  it "shows the next card and moves the progress when the visitor likes" do
    first_id = displayed_anime_id

    click_button "J'aime cet anime"

    expect(page).to have_progress(2)
    expect(page).to have_css(visible_slot, count: 1)
    expect(displayed_anime_id).not_to eq(first_id)
  end

  it "records the like for the anime that was on screen" do
    first_id = displayed_anime_id

    click_button "J'aime cet anime"
    expect(page).to have_progress(2)

    expect(Swipe.last).to have_attributes(anime_id: first_id, liked: true)
  end

  it "records the pass for the anime that was on screen" do
    first_id = displayed_anime_id

    click_button "Passer cet anime"
    expect(page).to have_progress(2)

    expect(Swipe.last).to have_attributes(anime_id: first_id, liked: false)
  end

  it "keeps counting down while the visitor swipes" do
    click_button "Passer cet anime"
    expect(page).to have_progress(2)

    click_button "J'aime cet anime"
    expect(page).to have_text(/dernier anime/i)
    expect(Swipe.count).to eq(2)
  end
end
