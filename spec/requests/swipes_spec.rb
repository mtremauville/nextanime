require "rails_helper"

RSpec.describe "Swipes", type: :request do
  let(:document) { Capybara.string(response.body) }

  describe "GET /" do
    it "is open to visitors without an account" do
      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "builds the deck with the swipe deck query" do
      deck_query = instance_double(SwipeDeckQuery, call: [])
      allow(SwipeDeckQuery).to receive(:new).and_return(deck_query)

      get root_path

      expect(deck_query).to have_received(:call)
    end

    context "with anime in the catalog" do
      before do
        create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg")
        get root_path
      end

      it "shows the deck with its progress" do
        expect(document).to have_css("section[aria-label='Deck de cartes']")
        expect(document).to have_text("Anime 1 / 3")
      end

      it "shows one card per anime" do
        expect(document).to have_css("article.na-swipe-card", count: 3, visible: :all)
      end
    end

    context "with an empty catalog" do
      before { get root_path }

      it "explains that there is nothing to swipe yet" do
        expect(document).to have_text("Le catalogue est vide")
        expect(document).to have_no_css("section[aria-label='Deck de cartes']")
      end
    end
  end
end
