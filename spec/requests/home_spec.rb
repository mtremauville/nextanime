require "rails_helper"

RSpec.describe "Home", type: :request do
  let(:document) { Capybara.string(response.body) }

  describe "GET /" do
    context "for a visitor" do
      before { get root_path }

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "shows the promise of the app" do
        expect(document).to have_css("h1", text: "Ton prochain anime se cache dans tes goûts.")
      end
    end

    context "for a visitor, in the hero" do
      before { get root_path }

      it "invites to start the discovery without an account" do
        expect(document).to have_link("Découvrir mes recommandations", href: discover_path)
      end

      it "links to the release calendar" do
        expect(document).to have_link("Voir le calendrier", href: calendar_path)
      end

      it "says that the app is free and needs no sign up" do
        expect(document).to have_text("Gratuit · sans inscription")
      end
    end

    context "for a signed in user" do
      before { sign_in create(:user) }

      it "sends the user to the swipe deck" do
        get root_path

        expect(response).to redirect_to(discover_path)
      end
    end
  end
end
