require "rails_helper"

RSpec.describe "Authentication layout", type: :request do
  let(:document) { Capybara.string(response.body) }

  describe "GET /users/sign_in" do
    before { get new_user_session_path }

    it "succeeds" do
      expect(response).to have_http_status(:ok)
    end

    it "has no main navigation" do
      expect(document).to have_no_css("header.na-header")
      expect(document).to have_no_css("nav.na-tabbar")
    end

    it "has a single main landmark" do
      expect(document).to have_css("main#main", count: 1)
    end

    it "keeps the skip link to the main content" do
      expect(document).to have_link("Aller au contenu", href: "#main")
    end

    it "applies the stored theme" do
      expect(document).to have_css("body[data-controller='theme']")
    end

    it "shows the brand panel" do
      expect(document).to have_css(".na-auth__brand", text: "Ton prochain anime se cache dans tes goûts")
      expect(document).to have_link("NextAnime", href: root_path)
    end

    it "offers a way back to the home page" do
      expect(document).to have_link("Retour à l'accueil", href: root_path)
    end
  end

  describe "flash messages" do
    it "shows the failure alert after a wrong password" do
      create(:user, email: "mika@example.com")

      post user_session_path, params: { user: { email: "mika@example.com", password: "wrong-password" } }

      expect(document).to have_css(".na-alert--danger[role='alert']")
    end
  end
end
