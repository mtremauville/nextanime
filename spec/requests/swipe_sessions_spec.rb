require "rails_helper"

RSpec.describe "Swipe sessions", type: :request do
  before { create_list(:anime, 25, cover_image_url: "https://img.test/cover.jpg") }

  def deck_ids
    Capybara.string(response.body)
            .all("[data-swipe-deck-target='slot']", visible: :all)
            .map { |slot| slot["data-anime-id"].to_i }
  end

  def swipe(anime_id, liked: true)
    post swipes_path, params: { anime_id: anime_id, liked: liked }
  end

  it "shows a session of 20 cards" do
    get root_path

    expect(deck_ids.size).to eq(20)
  end

  it "starts a new session at 0 %" do
    get root_path

    expect(response.body).to include("0 %")
    expect(response.body).to include(%(data-swipe-deck-offset-value="0"))
  end

  it "resumes the same cards when the page is reloaded" do
    get root_path
    first_visit = deck_ids

    get root_path

    expect(deck_ids).to eq(first_visit)
  end

  it "resumes the session without the cards already swiped" do
    get root_path
    drawn = deck_ids
    swipe(drawn.first)

    get root_path

    expect(deck_ids).to eq(drawn.drop(1))
  end

  it "keeps the progress of the whole session after a reload" do
    get root_path
    swipe(deck_ids.first)

    get root_path

    expect(response.body).to include("5 %")
    expect(response.body).to include(%(data-swipe-deck-offset-value="1"))
    expect(response.body).to include(%(data-swipe-deck-total-value="20"))
  end

  it "draws a new session once the 20 cards have been swiped" do
    get root_path
    drawn = deck_ids
    drawn.each { |anime_id| swipe(anime_id, liked: false) }

    get root_path

    expect(deck_ids.size).to eq(5)
    expect(deck_ids & drawn).to be_empty
  end

  context "when signed in" do
    before { sign_in create(:user) }

    it "resumes the session without the cards already swiped" do
      get root_path
      drawn = deck_ids
      swipe(drawn.first)

      get root_path

      expect(deck_ids).to eq(drawn.drop(1))
    end
  end
end
