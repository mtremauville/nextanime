require "rails_helper"

RSpec.describe Atoms::AvatarComponent, type: :component do
  it "shows the initial of the name in capital letters" do
    render_inline(described_class.new(name: "mickael@example.com"))

    expect(page).to have_css("span.na-avatar", text: "M")
  end

  it "hides the avatar from assistive technologies" do
    render_inline(described_class.new(name: "mickael@example.com"))

    expect(page).to have_css("span.na-avatar[aria-hidden='true']")
  end

  it "falls back to a placeholder when the name is blank" do
    render_inline(described_class.new(name: "  "))

    expect(page).to have_css("span.na-avatar", text: "?")
  end
end
