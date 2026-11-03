require "rails_helper"

RSpec.describe Molecules::GuestAccessComponent, type: :component do
  before { render_inline(described_class.new) }

  it "separates the guest access from the form" do
    expect(page).to have_css(".na-auth-divider", text: "ou")
  end

  it "links to the swipe page as an outline button" do
    expect(page).to have_css("a.btn-na-outline[href='/']", text: "Essayer sans compte")
  end

  it "explains that the profile is only saved with an account" do
    expect(page).to have_text("Tu peux swiper tout de suite. Ton profil ne sera sauvegardé qu'avec un compte.")
  end
end
