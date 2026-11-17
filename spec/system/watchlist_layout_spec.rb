require "rails_helper"

RSpec.describe "Watchlist layout on a phone", type: :system, js: true do
  include Warden::Test::Helpers

  let(:user) { create(:user) }

  before do
    page.current_window.resize_to(393, 852)
    create(:watchlist_entry, :watching, user: user, anime: create(:anime, episodes: 13))
    Warden.test_mode!
    login_as(user, scope: :user)
  end

  after { Warden.test_reset! }

  def rect_of(selector)
    page.evaluate_script(<<~JS)
      (() => {
        const box = document.querySelector('#{selector}').getBoundingClientRect()
        return { top: box.top, right: box.right, bottom: box.bottom, left: box.left }
      })()
    JS
  end

  def visit_the_watchlist
    visit "/watchlist"
    expect(page).to have_css(".na-watch-row button", minimum: 3)
  end

  it "keeps the minus and plus buttons on one line, beside the bar" do
    visit_the_watchlist

    minus = rect_of('.na-watch-row button[aria-label^="Un épisode de moins"]')
    plus = rect_of('.na-watch-row button[aria-label^="Un épisode de plus"]')
    expect(minus["top"]).to eq(plus["top"])
  end

  it "puts the delete button in the top right corner of the card, like the mockup" do
    visit_the_watchlist

    card = rect_of(".na-watch-row")
    trash = rect_of('.na-watch-row button[aria-label^="Retirer"]')
    minus = rect_of('.na-watch-row button[aria-label^="Un épisode de moins"]')

    expect(trash["top"] - card["top"]).to be <= 16, "The delete button sits #{trash['top'] - card['top']} px below the top of the card"
    expect(card["right"] - trash["right"]).to be <= 16, "The delete button sits #{card['right'] - trash['right']} px from the right edge"
    expect(trash["bottom"]).to be < minus["top"], "The delete button should be above the progress buttons"
  end
end
