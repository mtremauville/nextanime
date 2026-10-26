require "rails_helper"

RSpec.describe "Navigation", type: :request do
  pages = {
    "/" => "Découvrir",
    "/catalogue" => "Catalogue",
    "/recos" => "Recos",
    "/watchlist" => "Watchlist",
    "/calendrier" => "Calendrier"
  }

  let(:document) { Capybara.string(response.body) }

  pages.each do |path, title|
    describe "GET #{path}" do
      before { get path }

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "shows the page title" do
        expect(document).to have_css("main h1", text: title)
      end

      it "marks the page as current in the tab bar" do
        expect(document).to have_css("nav[aria-label='Onglets'] a[aria-current='page']", count: 1, text: title)
      end
    end
  end

  describe "layout" do
    before { get "/" }

    it "wraps the page in a main landmark" do
      expect(document).to have_css("main#main")
    end

    it "offers a skip link to the main content" do
      expect(document).to have_css("a.visually-hidden-focusable[href='#main']")
    end
  end
end
