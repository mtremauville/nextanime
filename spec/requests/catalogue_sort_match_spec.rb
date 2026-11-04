require "rails_helper"

RSpec.describe "Catalogue sort by match", type: :request do
  def titles
    Capybara.string(response.body).all("[data-role='catalogue-item'] h2").map { |node| node.text.strip }
  end

  let(:thriller) { create(:genre, name: "Thriller") }
  let(:comedy) { create(:genre, name: "Comédie") }
  let(:user) { create(:user) }

  before do
    sign_in user
    create(:anime, title_romaji: "Thriller", genres: [ thriller ], popularity: 5)
    create(:anime, title_romaji: "Comedy", genres: [ comedy ], popularity: 500)
  end

  context "when the person has liked something" do
    before { user.create_taste_profile!.record_swipe(create(:anime, title_romaji: "Liked", genres: [ thriller ], popularity: 1), liked: true) }

    it "ranks by match by default, the most popular first among equals" do
      get catalogue_path

      expect(titles).to eq(%w[Thriller Liked Comedy])
    end

    it "ranks by match when it is asked" do
      get catalogue_path, params: { sort: "match" }

      expect(titles).to eq(%w[Thriller Liked Comedy])
    end

    it "ranks by popularity when it is asked" do
      get catalogue_path, params: { sort: "popularity" }

      expect(titles).to eq(%w[Comedy Thriller Liked])
    end
  end

  context "when the person has only passed" do
    before { user.create_taste_profile!.record_swipe(create(:anime, title_romaji: "Passed", genres: [ thriller ], popularity: 1), liked: false) }

    it "ranks by popularity by default" do
      get catalogue_path

      expect(titles).to eq(%w[Comedy Thriller Passed])
    end

    it "ranks by popularity even when the match is asked" do
      get catalogue_path, params: { sort: "match" }

      expect(titles).to eq(%w[Comedy Thriller Passed])
    end
  end
end
