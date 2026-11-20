require "rails_helper"

RSpec.describe Molecules::GuestBannerComponent, type: :component do
  before { render_inline(described_class.new) }

  it "is announced politely to assistive technologies" do
    expect(page).to have_css("div.na-guest-banner[role='status']")
  end

  it "names the guest mode" do
    expect(page).to have_css(".na-guest-banner__title", text: "Mode invité")
  end

  it "explains that the profile stays on this device" do
    expect(page).to have_text("Ton profil est gardé sur cet appareil. Crée un compte pour le retrouver partout.")
  end

  it "links to the sign up page" do
    expect(page).to have_link("Créer un compte pour le garder →", href: "/users/sign_up")
  end
end
