require "rails_helper"

RSpec.describe "Choosing a country", type: :request do
  let(:user) { create(:user) }

  describe "PATCH /country as a visitor" do
    it "remembers the country in a cookie" do
      patch country_path, params: { country: "BE" }

      expect(response.cookies["country"]).to eq("BE")
    end

    it "keeps the cookie out of the reach of scripts and of other sites" do
      patch country_path, params: { country: "BE" }

      cookie = Array(response.headers["Set-Cookie"]).find { |header| header.start_with?("country=") }
      expect(cookie).to match(/httponly/i).and match(/samesite=lax/i)
    end

    it "forgets the country after a day" do
      patch country_path, params: { country: "BE" }

      cookie = Array(response.headers["Set-Cookie"]).find { |header| header.start_with?("country=") }
      expires_at = Time.httpdate(cookie[/expires=([^;]+)/i, 1])
      expect(expires_at).to be_within(1.minute).of(1.day.from_now)
    end

    it "goes back to the page that was being read" do
      patch country_path, params: { country: "BE" }, headers: { "Referer" => "http://www.example.com/catalogue" }

      expect(response).to redirect_to("http://www.example.com/catalogue")
    end

    it "goes to the home page when there is no page to go back to" do
      patch country_path, params: { country: "BE" }

      expect(response).to redirect_to(root_path)
    end

    it "never goes to another site" do
      patch country_path, params: { country: "BE" }, headers: { "Referer" => "https://evil.example.org/page" }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /country as a member" do
    before { sign_in user }

    it "stores the country of the member" do
      patch country_path, params: { country: "CH" }

      expect(user.reload.country).to eq("CH")
    end

    it "sets no cookie" do
      patch country_path, params: { country: "CH" }

      expect(response.cookies).not_to have_key("country")
    end
  end

  describe "PATCH /country with a country that is not supported" do
    it "does not remember it for a visitor" do
      patch country_path, params: { country: "JP" }

      expect(response.cookies).not_to have_key("country")
      expect(response).to redirect_to(root_path)
    end

    it "does not store it for a member" do
      sign_in user

      patch country_path, params: { country: "JP" }

      expect(user.reload.country).to eq("FR")
    end

    it "ignores a request without a country" do
      patch country_path

      expect(response.cookies).not_to have_key("country")
      expect(response).to redirect_to(root_path)
    end
  end
  describe "the selector of the header" do
    def selector = Capybara.string(response.body)

    it "shows France to a visitor who chose nothing" do
      get discover_path

      expect(selector).to have_select("country", selected: "France")
    end

    it "shows the country that a visitor chose" do
      patch country_path, params: { country: "BE" }

      get discover_path

      expect(selector).to have_select("country", selected: "Belgique")
    end

    it "shows the country of a member" do
      sign_in create(:user, country: "CH")

      get discover_path

      expect(selector).to have_select("country", selected: "Suisse")
    end
  end
end
