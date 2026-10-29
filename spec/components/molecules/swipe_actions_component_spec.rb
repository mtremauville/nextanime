require "rails_helper"

RSpec.describe Molecules::SwipeActionsComponent, type: :component do
  before { render_inline(described_class.new) }

  it "offers to pass the anime with a plain button" do
    expect(page).to have_css("button[type=button][aria-label='Passer cet anime']")
  end

  it "offers to like the anime with a plain button" do
    expect(page).to have_css("button[type=button][aria-label='J\\'aime cet anime']")
  end

  it "shows a visible label under each button" do
    expect(page).to have_css(".na-swipe-actions__label", text: "Passer")
    expect(page).to have_css(".na-swipe-actions__label", text: "J'aime")
  end

  it "hides the icons from assistive technologies" do
    expect(page).to have_css("button i[aria-hidden='true']", count: 2)
  end

  it "reminds the keyboard shortcuts" do
    expect(page).to have_text("← Passer · J'aime →")
  end
end
