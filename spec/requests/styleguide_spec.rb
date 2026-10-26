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

    it "shows both button variants" do
      expect(response.body).to include("btn-na-primary", "btn-na-outline")
    end

    it "shows tags in both tones" do
      expect(response.body).to include("na-tag--cyan")
      expect(response.body).to include(">Thriller<")
    end

    it "shows the match badge" do
      expect(response.body).to include("na-badge-match")
    end

    it "shows accessible meters" do
      expect(response.body).to include('role="progressbar"')
    end

    it "shows form fields including an error state" do
      expect(response.body).to include("form-control", "is-invalid")
    end

    it "shows poster cards" do
      expect(response.body).to include("na-poster-card", "stretched-link")
    end
  end
end
