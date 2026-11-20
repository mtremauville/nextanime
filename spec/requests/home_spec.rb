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

    context "for a visitor, further down the page" do
      before { get root_path }

      it "explains how the app works" do
        expect(document).to have_css("h2", text: "De tes goûts à tes découvertes")
      end

      it "gives the three steps" do
        expect(document).to have_css("ol.na-steps > li", count: 3)
      end

      it "shows an example of recommendation" do
        expect(document).to have_css("section.na-example ul.na-example__recos > li", count: 2)
      end

      it "says that this recommendation is only an example" do
        expect(document).to have_css("section.na-example .na-tag", text: "Exemple")
      end

      it "lists the three features of the app" do
        expect(document).to have_css("ul.na-features > li", count: 3)
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
