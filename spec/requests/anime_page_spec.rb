require "rails_helper"

RSpec.describe "Anime page", type: :request do
  let(:thriller) { create(:genre, name: "Thriller") }
  let(:description) { "Dr Tenma saves a boy.<br><i>Dark.</i>" }
  let(:anime) do
    create(:anime, title_romaji: "Monster", title_english: nil, description: description,
                   format: :tv, episodes: 74, genres: [ thriller ])
  end
  let(:document) { Capybara.string(response.body) }

  describe "GET /anime/:id" do
    it "shows the anime to a visitor" do
      get anime_path(anime)

      expect(response).to have_http_status(:ok)
      expect(document).to have_css("h1", text: "Monster")
    end

    it "keeps the line breaks and the italics of the synopsis" do
      get anime_path(anime)

      expect(document).to have_css(".na-anime-page__synopsis i", text: "Dark.")
      expect(document).to have_css(".na-anime-page__synopsis br")
    end

    context "with a synopsis that carries more than simple formatting" do
      let(:description) { "Safe <img src=x onerror=boom()> text<script>boom()</script>" }

      it "drops it" do
        get anime_path(anime)

        expect(document).to have_text("Safe")
        expect(document).to have_no_css(".na-anime-page__synopsis img, .na-anime-page__synopsis script")
        expect(response.body).not_to include("onerror")
      end
    end

    it "ranks the tags with a gauge" do
      create(:anime_tag, anime: anime, tag: create(:tag, name: "Démons"), rank: 92)

      get anime_path(anime)

      expect(document).to have_css(".na-tag-gauges [data-role='tag']", text: "Démons")
    end

    it "lists the information about the anime" do
      get anime_path(anime)

      expect(document).to have_css(".na-info-card dd", text: "74")
    end

    it "links a visitor back to the catalogue, the recommendations being for members" do
      get anime_path(anime)

      expect(document).to have_link("← Retour au catalogue", href: catalogue_path)
      expect(document).to have_no_css("a.na-anime-page__back[href='#{recommendations_path}']")
    end

    it "links a member back to the recommendations" do
      sign_in create(:user)

      get anime_path(anime)

      expect(document).to have_link("← Retour aux recommandations", href: recommendations_path)
    end

    it "answers not found for an unknown anime" do
      get anime_path(0)

      expect(response).to have_http_status(:not_found)
    end

    it "does not create a taste profile just to look" do
      expect { get anime_path(anime) }.not_to change(TasteProfile, :count)
    end

    context "without a taste profile" do
      it "shows no match" do
        get anime_path(anime)

        expect(document).to have_no_css(".na-match-panel")
      end
    end

    context "with passes only" do
      it "shows no match" do
        user = create(:user)
        sign_in user
        user.create_taste_profile!.record_swipe(create(:anime), liked: false)

        get anime_path(anime)

        expect(document).to have_no_css(".na-match-panel")
      end
    end

    context "with likes" do
      before do
        user = create(:user)
        sign_in user
        user.create_taste_profile!.record_swipe(create(:anime, genres: [ thriller ]), liked: true)
      end

      it "shows how well the anime matches the taste" do
        get anime_path(anime)

        expect(document).to have_css(".na-match-panel__percent", text: /\d+%/)
      end

      it "says why it matches" do
        get anime_path(anime)

        expect(document).to have_css(".na-match-panel__text", text: "Parce que tu aimes Thriller.")
      end
    end
  end

  describe "the watchlist on the page of an anime" do
    context "with a visitor" do
      it "invites them to create an account and offers no addition" do
        get anime_path(anime)

        expect(document).to have_link("Créer un compte pour ajouter à ma watchlist", href: new_user_registration_path)
        expect(document).to have_no_css("form[action='#{anime_watchlist_entry_path(anime)}']")
      end
    end

    context "with a member" do
      let(:member) { create(:user) }

      before { sign_in member }

      it "offers to add an anime that is not in their list" do
        get anime_path(anime)

        expect(document).to have_css("form[action='#{anime_watchlist_entry_path(anime)}'] button", text: "+ Ajouter à ma watchlist")
      end

      it "says an anime of their list is in it" do
        create(:watchlist_entry, user: member, anime: anime)

        get anime_path(anime)

        expect(document).to have_link("Dans ma watchlist", href: watchlist_path)
        expect(document).to have_no_button("+ Ajouter à ma watchlist")
      end

      it "does not count the watchlist of someone else" do
        create(:watchlist_entry, user: create(:user), anime: anime)

        get anime_path(anime)

        expect(document).to have_button("+ Ajouter à ma watchlist")
      end
    end
  end
  describe "GET /anime/:id where to watch" do
    let(:crunchyroll) { create(:streaming_platform, name: "Crunchyroll", slug: "crunchyroll") }
    let(:watch_page) { "https://www.themoviedb.org/tv/1/watch?locale=FR" }

    context "when TMDB knows the anime" do
      before { create(:tmdb_match, anime: anime, watch_links: { "FR" => watch_page }) }

      it "shows the platforms that offer it in France, linked to the search of their title, with the watch page of TMDB in the credit" do
        create(:streaming_availability, anime: anime, streaming_platform: crunchyroll, country_code: "FR")

        get anime_path(anime)

        expect(document).to have_css(".na-where-to-watch__country", text: "France")
        expect(document).to have_css(".na-platform-row__name", text: "Crunchyroll")
        expect(document).to have_css("a.na-platform-row[href^='https://www.crunchyroll.com/search?q=']")
        expect(document).to have_css(".na-where-to-watch__credit a[href='#{watch_page}']")
      end

      it "does not show the offers of another country" do
        create(:streaming_availability, anime: anime, streaming_platform: crunchyroll, country_code: "BE")

        get anime_path(anime)

        expect(document).to have_no_css(".na-platform-row")
        expect(document).to have_css(".na-where-to-watch__empty-title", text: "Pas encore disponible en France")
      end

      it "shows one row for a platform that has several offers" do
        create(:streaming_availability, anime: anime, streaming_platform: crunchyroll, country_code: "FR", offer_type: :flatrate)
        create(:streaming_availability, anime: anime, streaming_platform: crunchyroll, country_code: "FR", offer_type: :ads)

        get anime_path(anime)

        expect(document).to have_css(".na-platform-row", count: 1)
        expect(document).to have_css(".na-platform-row__offer", text: "Abonnement · Gratuit avec publicité")
      end

      it "shows the block above the information card" do
        get anime_path(anime)

        expect(document).to have_css(".na-anime-page__side > .na-where-to-watch + .na-info-card")
      end
    end

    context "when another country was chosen" do
      before do
        create(:tmdb_match, anime: anime, watch_links: {})
        create(:streaming_availability, anime: anime, streaming_platform: crunchyroll, country_code: "BE")
      end

      it "shows the offers of the country that a visitor chose" do
        patch country_path, params: { country: "BE" }

        get anime_path(anime)

        expect(document).to have_css(".na-where-to-watch__country", text: "Belgique")
        expect(document).to have_css(".na-platform-row__name", text: "Crunchyroll")
      end

      it "shows the offers of the country of a member, whatever the cookie says" do
        patch country_path, params: { country: "CH" }
        sign_in create(:user, country: "BE")

        get anime_path(anime)

        expect(document).to have_css(".na-where-to-watch__country", text: "Belgique")
      end

      it "falls back to France when the cookie holds a country that is not supported" do
        cookies[:country] = "JP"

        get anime_path(anime)

        expect(document).to have_css(".na-where-to-watch__country", text: "France")
        expect(document).to have_no_css(".na-platform-row")
      end
    end

    it "hides the block when TMDB did not find the anime" do
      create(:tmdb_match, :unmatched, anime: anime)

      get anime_path(anime)

      expect(document).to have_no_css(".na-where-to-watch")
    end

    it "hides the block when the anime was never looked up on TMDB" do
      get anime_path(anime)

      expect(document).to have_no_css(".na-where-to-watch")
    end
  end
end
