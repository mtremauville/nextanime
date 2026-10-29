require "rails_helper"

RSpec.describe "Swipes", type: :request do
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
  end
end
