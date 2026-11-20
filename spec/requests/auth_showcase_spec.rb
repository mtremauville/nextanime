require "rails_helper"

RSpec.describe "Showcase of the authentication pages", type: :request do
  let(:document) { Capybara.string(response.body) }

  %i[new_user_session_path new_user_registration_path new_user_password_path].each do |route|
    it "shows the covers of the anime on the posters of #{route}" do
      create(:anime, anilist_id: 437, cover_image_url: "https://img.test/perfect-blue.jpg")

      get public_send(route)

      expect(document).to have_css(".na-showcase img.na-showcase-poster__image[src='https://img.test/perfect-blue.jpg']")
    end
  end

  it "keeps the gradients when the anime are not in the database" do
    get new_user_session_path

    expect(document).to have_css(".na-showcase .na-showcase-poster", count: 3)
    expect(document).to have_no_css(".na-showcase img")
  end
end
