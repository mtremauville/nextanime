require "rails_helper"

RSpec.describe "Swiping while signed in", type: :request do
  let(:user) { create(:user) }
  let!(:seen) { create(:anime, cover_image_url: "https://example.com/seen.jpg") }
  let!(:unseen) { create(:anime, cover_image_url: "https://example.com/unseen.jpg") }

  before { sign_in user }

  def page
    Capybara.string(response.body)
  end

  describe "POST /swipes" do
    it "records the swipe on the profile of the account" do
      post swipes_path, params: { anime_id: seen.id, liked: true }

      expect(user.reload.taste_profile.swiped_anime_ids).to eq([ seen.id ])
    end

    it "reuses the same profile for every swipe" do
      post swipes_path, params: { anime_id: seen.id, liked: true }
      post swipes_path, params: { anime_id: unseen.id, liked: false }

      expect(TasteProfile.where(user: user).count).to eq(1)
      expect(user.reload.taste_profile.swiped_anime_ids).to contain_exactly(seen.id, unseen.id)
    end

    it "creates no guest profile and no guest cookie" do
      post swipes_path, params: { anime_id: seen.id, liked: true }

      expect(TasteProfile.where.not(session_token: nil)).to be_empty
      expect(cookies[:taste_session]).to be_blank
    end
  end

  describe "GET /" do
    it "leaves out the anime the account already swiped" do
      TasteProfile.create!(user: user).record_swipe(seen, liked: false)

      get root_path

      expect(page).to have_css("[data-anime-id='#{unseen.id}']", visible: :all)
      expect(page).to have_no_css("[data-anime-id='#{seen.id}']", visible: :all)
    end

    it "does not create a profile just by looking at the deck" do
      expect { get root_path }.not_to change(TasteProfile, :count)
    end
  end
end
