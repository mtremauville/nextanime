require "rails_helper"

RSpec.describe "Swiping the deck", type: :system, js: true do
  let(:visible_slot) { ".na-swipe-deck__slot:not([hidden])" }

  before do
    page.current_window.resize_to(1400, 900)
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

  describe "with the keyboard" do
    it "likes with the right arrow" do
      first_id = displayed_anime_id

      find("body").send_keys(:arrow_right)

      expect(page).to have_progress(2)
      expect(Swipe.last).to have_attributes(anime_id: first_id, liked: true)
    end

    it "passes with the left arrow" do
      first_id = displayed_anime_id

      find("body").send_keys(:arrow_left)

      expect(page).to have_progress(2)
      expect(Swipe.last).to have_attributes(anime_id: first_id, liked: false)
    end

    it "leaves the arrows to the country selector" do
      first_id = displayed_anime_id

      find("select", match: :first).send_keys(:arrow_right)

      expect(displayed_anime_id).to eq(first_id)
      expect(Swipe.count).to eq(0)
    end

    it "leaves the browser shortcuts alone" do
      first_id = displayed_anime_id

      find("body").send_keys([ :alt, :arrow_left ])

      expect(displayed_anime_id).to eq(first_id)
      expect(Swipe.count).to eq(0)
    end
  end

  describe "by dragging the card" do
    def drag_card_by(pixels)
      card = find("#{visible_slot} .na-swipe-card")
      page.driver.browser.action.move_to(card.native).click_and_hold.move_by(pixels, 0).release.perform
    end

    it "likes when the card is dragged to the right" do
      first_id = displayed_anime_id

      drag_card_by(180)

      expect(page).to have_progress(2)
      expect(Swipe.last).to have_attributes(anime_id: first_id, liked: true)
    end

    it "passes when the card is dragged to the left" do
      first_id = displayed_anime_id

      drag_card_by(-180)

      expect(page).to have_progress(2)
      expect(Swipe.last).to have_attributes(anime_id: first_id, liked: false)
    end

    it "keeps the card when the drag is too short" do
      first_id = displayed_anime_id

      drag_card_by(30)

      expect(displayed_anime_id).to eq(first_id)
      expect(Swipe.count).to eq(0)
    end
  end

  it "ends the deck with a link to the recommendations" do
    3.times { click_button "J'aime cet anime" }

    within("#swipe-deck") do
      expect(page).to have_text(/tu as tout vu/i)
      expect(page).to have_link("Voir mes recommandations", href: recommendations_path)
    end
    expect(page).to have_no_button("J'aime cet anime")
    expect(Swipe.count).to eq(3)
  end
end
