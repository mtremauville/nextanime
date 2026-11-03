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

    it "puts the brand and the way back in a header above the main landmark" do
      expect(document).to have_css("header.na-auth__header a.na-brand", text: "NextAnime")
      expect(document).to have_css("header.na-auth__header a.na-auth__back", text: "Retour à l'accueil")
      expect(document).to have_no_css("main#main a.na-auth__back")
    end

    it "lays the presentation and the form side by side in the main landmark" do
      expect(document).to have_css("main#main > section.na-auth__brand[aria-label='Présentation']")
      expect(document).to have_css("main#main > section.na-auth__card")
      expect(document).to have_no_css("aside")
    end

    it "shows the poster showcase in the presentation" do
      expect(document).to have_css("section.na-auth__brand .na-showcase .na-showcase-poster", count: 3)
    end

    it "offers a short and a full label for the way back" do
      expect(document).to have_css("a.na-auth__back .na-auth__back-full", text: "Retour à l'accueil")
      expect(document).to have_css("a.na-auth__back .na-auth__back-short", text: "Accueil")
    end
  end

  describe "flash messages" do
    it "shows the failure alert after a wrong password" do
      create(:user, email: "mika@example.com")

      post user_session_path, params: { user: { email: "mika@example.com", password: "wrong-password" } }

      expect(document).to have_css(".na-auth__card .na-alert--danger[role='alert']")
    end
  end
end
