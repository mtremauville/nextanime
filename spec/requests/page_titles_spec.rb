require "rails_helper"

RSpec.describe "Page titles", type: :request do
  def title_of(path)
    get path
    expect(response).to have_http_status(:ok)
    Nokogiri::HTML(response.body).at_css("title").text
  end

  {
    "the swipe page" => [ "/", "Découvrir · NextAnime" ],
    "the catalogue" => [ "/catalogue", "Catalogue · NextAnime" ],
    "the privacy policy" => [ "/confidentialite", "Politique de confidentialité · NextAnime" ]
  }.each do |page, (path, title)|
    it "titles #{page}" do
      expect(title_of(path)).to eq(title)
    end
  end

  context "when signed in" do
    before { sign_in create(:user) }

    {
      "the recommendations" => [ "/recos", "Mes recommandations · NextAnime" ],
      "the watchlist" => [ "/watchlist", "Ma watchlist · NextAnime" ],
      "the calendar" => [ "/calendrier", "Calendrier · NextAnime" ],
      "the profile" => [ "/profil", "Mon profil · NextAnime" ]
    }.each do |page, (path, title)|
      it "titles #{page}" do
        expect(title_of(path)).to eq(title)
      end
    end
  end

  describe "the page of an anime" do
    it "is titled with the title of the anime" do
      anime = create(:anime, title_romaji: "Perfect Blue", title_english: nil)

      expect(title_of(anime_path(anime))).to eq("Perfect Blue · NextAnime")
    end

    it "shows an ampersand once, not escaped twice" do
      anime = create(:anime, title_romaji: "Kaguya & Ishigami", title_english: nil)

      expect(title_of(anime_path(anime))).to eq("Kaguya & Ishigami · NextAnime")
    end
  end
end
