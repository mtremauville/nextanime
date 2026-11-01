require "rails_helper"

RSpec.describe "Reset on the swipe page", type: :request do
  let(:page) { Capybara.string(response.body) }

  before { create(:anime, cover_image_url: "https://img.test/cover.jpg") }

  def have_reset_modal
    have_css("dialog#reset-profile form[action='#{reset_taste_profile_path}']")
  end

  context "as a visitor" do
    before { get root_path }

    it "offers to reset the taste profile" do
      expect(page).to have_button("Réinitialiser mon profil")
    end

    it "asks for confirmation before erasing anything" do
      expect(page).to have_reset_modal
    end
  end

  context "when signed in" do
    before do
      sign_in create(:user)
      get root_path
    end

    it "offers to reset the taste profile as well" do
      expect(page).to have_button("Réinitialiser mon profil")
      expect(page).to have_reset_modal
    end
  end
end
