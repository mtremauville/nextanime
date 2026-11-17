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

  def row_buttons
    page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll(".na-watch-row__actions button")).map((button) => {
        const box = button.getBoundingClientRect()
        return {
          label: button.getAttribute("aria-label") || button.textContent.trim(),
          top: Math.round(box.top),
          width: Math.round(box.width),
          height: Math.round(box.height)
        }
      })
    JS
  end

  it "keeps the buttons of a row on one line, beside the bar" do
    visit "/watchlist"
    expect(page).to have_css(".na-watch-row__actions button", minimum: 3)

    rendered = row_buttons.select { |button| button["width"].positive? && button["height"].positive? }
    lines = rendered.map { |button| button["top"] }.uniq
    expect(lines.size).to eq(1), "The buttons sit on #{lines.size} lines: #{row_buttons.inspect}"
  end
end
