require "rails_helper"

RSpec.describe "Styleguide", type: :request do
  describe "GET /styleguide" do
    before { get styleguide_path }

    it "returns a successful response" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the page in the dark theme by default" do
      expect(response.body).to include('data-bs-theme="dark"')
    end

    it "renders the theme toggle" do
      expect(response.body).to include('data-controller="theme"')
    end

    it "lists every color token" do
      StyleguideController::COLOR_TOKENS.each do |token|
        expect(response.body).to include(token)
      end
    end

    it "shows the three font families" do
      expect(response.body).to include("Chakra Petch", "Manrope", "DotGothic16")
    end
  end
end
