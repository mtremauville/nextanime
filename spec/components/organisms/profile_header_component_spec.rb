require "rails_helper"

RSpec.describe Organisms::ProfileHeaderComponent, type: :component do
  let(:user) do
    build(:user, username: "Mika", email: "mika@example.com", created_at: Time.zone.local(2026, 10, 12))
  end

  def render_header(&block)
    render_inline(described_class.new(user: user), &block)
  end

  it "introduces the page with an eyebrow" do
    render_header

    expect(page).to have_css(".na-profile-header__eyebrow", text: "Mon profil")
  end

  it "names the user in the main heading" do
    render_header

    expect(page).to have_css("h1", text: "Mika")
  end

  it "shows the e-mail address and since when the user is a member" do
    render_header

    expect(page).to have_css(".na-profile-header__meta", text: "mika@example.com · membre depuis octobre 2026")
  end

  it "shows the initial of the name in an avatar hidden from assistive technologies" do
    render_header

    expect(page).to have_css(".na-profile-header__avatar[aria-hidden=true]", exact_text: "M")
  end

  it "takes the initial from the e-mail address when there is no username" do
    user.username = nil
    user.email = "zoe@example.com"
    render_header

    expect(page).to have_css(".na-profile-header__avatar", exact_text: "Z")
  end

  it "places the content it is given next to the identity" do
    render_header { "Les statistiques" }

    expect(page).to have_css(".na-profile-header__stats", text: "Les statistiques")
  end
end
