require "rails_helper"

RSpec.describe "Swiping very fast as a new visitor", type: :system, js: true do
  before do
    create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg")
    visit root_path
  end

  def wait_for_swipes(count)
    Timeout.timeout(Capybara.default_max_wait_time) { sleep 0.05 until Swipe.count == count }
  end

  it "keeps every swipe on one taste profile when the likes follow each other without a pause" do
    like = find_button("J'aime cet anime")

    page.execute_script("for (let i = 0; i < 2; i++) arguments[0].click()", like)
    wait_for_swipes(2)

    expect(TasteProfile.count).to eq(1)
    expect(TasteProfile.first.swipes.count).to eq(2)
  end
end
