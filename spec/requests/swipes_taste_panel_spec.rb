require "rails_helper"

RSpec.describe "Taste profile panel on the swipe page", type: :request do
  let(:page) { Capybara.string(response.body) }

  before { create(:anime, cover_image_url: "https://img.test/cover.jpg") }

  context "as a visitor" do
    before { get root_path }

    it "offers no way to reset the taste profile" do
      expect(page).to have_no_button("Réinitialiser mon profil")
      expect(page).to have_no_css("dialog#reset-profile", visible: :all)
    end
  end

  context "when signed in" do
    before do
      sign_in create(:user)
      get root_path
    end

    it "offers no way to reset the taste profile either" do
      expect(page).to have_no_button("Réinitialiser mon profil")
      expect(page).to have_no_css("dialog#reset-profile", visible: :all)
    end

    it "links to the full profile" do
      expect(page).to have_link("Voir mon profil complet", href: profile_path)
    end
  end
end
