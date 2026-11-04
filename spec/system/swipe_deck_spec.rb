require "rails_helper"

RSpec.describe "Swiping the deck", type: :system, js: true do
  let(:visible_slot) { ".na-swipe-deck__slot:not([hidden])" }

  before do
    create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg")
    visit root_path
  end

  # The guard keeps "0 %" from matching inside "100 %".
  def have_percent(value)
    have_text(/(?<!\d)#{value} %/)
  end

  def displayed_anime_id
    find(visible_slot)["data-anime-id"].to_i
  end

  it "starts on the first card" do
    expect(page).to have_percent(0)
    expect(page).to have_css(visible_slot, count: 1)
  end

  it "shows the next card and moves the progress when the visitor likes" do
    first_id = displayed_anime_id

    click_button "J'aime cet anime"

    expect(page).to have_percent(33)
    expect(page).to have_css(visible_slot, count: 1)
    expect(displayed_anime_id).not_to eq(first_id)
  end

  it "records the like for the anime that was on screen" do
    first_id = displayed_anime_id

    click_button "J'aime cet anime"
    expect(page).to have_percent(33)

    expect(Swipe.last).to have_attributes(anime_id: first_id, liked: true)
  end

  it "records the pass for the anime that was on screen" do
    first_id = displayed_anime_id

    click_button "Passer cet anime"
    expect(page).to have_percent(33)

    expect(Swipe.last).to have_attributes(anime_id: first_id, liked: false)
  end

  it "moves the progress up while the visitor swipes" do
    click_button "Passer cet anime"
    expect(page).to have_percent(33)

    click_button "J'aime cet anime"
    expect(page).to have_percent(67)
    expect(Swipe.count).to eq(2)
  end

  describe "with the keyboard" do
    it "likes with the right arrow" do
      first_id = displayed_anime_id

      find("body").send_keys(:arrow_right)

      expect(page).to have_percent(33)
      expect(Swipe.last).to have_attributes(anime_id: first_id, liked: true)
    end

    it "passes with the left arrow" do
      first_id = displayed_anime_id

      find("body").send_keys(:arrow_left)

      expect(page).to have_percent(33)
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

      expect(page).to have_percent(33)
      expect(Swipe.last).to have_attributes(anime_id: first_id, liked: true)
    end

    it "passes when the card is dragged to the left" do
      first_id = displayed_anime_id

      drag_card_by(-180)

      expect(page).to have_percent(33)
      expect(Swipe.last).to have_attributes(anime_id: first_id, liked: false)
    end

    it "keeps the card when the drag is too short" do
      first_id = displayed_anime_id

      drag_card_by(30)

      expect(displayed_anime_id).to eq(first_id)
      expect(Swipe.count).to eq(0)
    end
  end

  it "ends the session with a link to the recommendations and a new session" do
    3.times { click_button "J'aime cet anime" }

    within("#swipe-deck") do
      expect(page).to have_text(/session terminée/i)
      expect(page).to have_link("Voir mes recommandations", href: recommendations_path)
      expect(page).to have_link("Nouvelle session", href: root_path)
    end
    expect(page).to have_no_button("J'aime cet anime")
    expect(Swipe.count).to eq(3)
  end

  it "starts a new session from the end of the previous one" do
    create_list(:anime, 2, cover_image_url: "https://img.test/cover.jpg")
    3.times { click_button "J'aime cet anime" }

    click_link "Nouvelle session"

    expect(page).to have_percent(0)
    expect(page).to have_css(visible_slot, count: 1)
    expect(page).to have_no_text(/session terminée/i)
  end

  describe "after a reload" do
    it "resumes the session without the cards already swiped" do
      first_id = displayed_anime_id

      click_button "J'aime cet anime"
      expect(page).to have_percent(33)

      visit root_path

      expect(page).to have_percent(33)
      expect(displayed_anime_id).not_to eq(first_id)
    end

    it "keeps counting from where the session was" do
      click_button "J'aime cet anime"
      expect(page).to have_percent(33)

      visit root_path
      click_button "J'aime cet anime"

      expect(page).to have_percent(67)
    end

    it "still ends the session on the last card" do
      click_button "J'aime cet anime"
      expect(page).to have_percent(33)

      visit root_path
      2.times { click_button "J'aime cet anime" }

      within("#swipe-deck") { expect(page).to have_text(/session terminée/i) }
      expect(Swipe.count).to eq(3)
    end
  end
end
