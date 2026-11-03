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
    describe "GET #{path} for a signed in user" do
      before do
        sign_in create(:user)
        get path
      end

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

  describe "tab bar for a visitor" do
    before { get "/catalogue" }

    it "offers the pages open to visitors" do
      %w[Découvrir Catalogue Recos Calendrier].each do |title|
        expect(document).to have_css("nav[aria-label='Onglets'] a", text: title)
      end
    end

    it "does not offer the watchlist" do
      expect(document).to have_no_css("nav[aria-label='Onglets'] a", text: "Watchlist")
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

  describe "GET /styleguide" do
    before { get "/styleguide" }

    it "has a single main landmark" do
      expect(document).to have_css("main", count: 1)
    end
  end
end
