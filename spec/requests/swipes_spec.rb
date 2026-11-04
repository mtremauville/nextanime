require "rails_helper"

RSpec.describe "Swipes", type: :request do
  let(:document) { Capybara.string(response.body) }

  describe "GET /" do
    it "is open to visitors without an account" do
      get root_path

      expect(response).to have_http_status(:ok)
    end

    it "builds the deck with the swipe deck query" do
      deck_query = instance_double(SwipeDeckQuery, call: [])
      allow(SwipeDeckQuery).to receive(:new).and_return(deck_query)

      get root_path

      expect(deck_query).to have_received(:call)
    end

    context "with anime in the catalog" do
    it "shows the taste profile panel without a profile link yet" do
      get root_path

      expect(response.body).to include("Genres et ambiances")
      expect(response.body).not_to include("Voir mon profil complet")
    end

    it "offers a visitor to save the profile by creating an account" do
      get root_path

      expect(Capybara.string(response.body)).to have_link("Sauvegarder mon profil →", href: new_user_registration_path)
    end

    it "offers no account link to a signed in user" do
      sign_in create(:user)

      get root_path

      expect(Capybara.string(response.body)).to have_no_link("Sauvegarder mon profil →")
    end

    it "shows the history panel linking to the recommendations" do
      get root_path

      expect(response.body).to include("Ton historique")
      expect(response.body).to include(%(href="#{recommendations_path}"))
    end
      before do
        create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg")
        get root_path
      end

      it "shows the deck with its progress" do
        expect(document).to have_css("section[aria-label='Deck de cartes']")
        expect(document).to have_text("0 %")
      end

      it "shows one card per anime" do
        expect(document).to have_css("article.na-swipe-card", count: 3, visible: :all)
      end
    end

    context "with an empty catalog" do
      before { get root_path }

      it "explains that there is nothing to swipe yet" do
        expect(document).to have_text("Le catalogue est vide")
        expect(document).to have_no_css("section[aria-label='Deck de cartes']")
      end
    end
  end

  describe "POST /swipes" do
    let(:anime) { create(:anime) }

    it "records a like for the visitor" do
      expect { post swipes_path, params: { anime_id: anime.id, liked: true } }
        .to change(Swipe, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(Swipe.last.liked).to be(true)
    end

    it "records a pass" do
      post swipes_path, params: { anime_id: anime.id, liked: false }

      expect(Swipe.last.liked).to be(false)
    end

    it "creates the visitor profile on the first swipe and reuses it afterwards" do
      other_anime = create(:anime)

      expect { post swipes_path, params: { anime_id: anime.id, liked: true } }
        .to change(TasteProfile, :count).by(1)
      expect { post swipes_path, params: { anime_id: other_anime.id, liked: false } }
        .not_to change(TasteProfile, :count)
      expect(TasteProfile.last.swipes.count).to eq(2)
    end

    it "keeps the profile in a signed cookie that scripts cannot read" do
      post swipes_path, params: { anime_id: anime.id, liked: true }

      expect(Array(response.headers["Set-Cookie"]).join("\n")).to match(/taste_session=[^;]+;.*HttpOnly/i)
    end

    it "ignores a forged cookie and starts a new profile" do
      cookies[:taste_session] = "forged"

      post swipes_path, params: { anime_id: anime.id, liked: true }

      expect(TasteProfile.where(session_token: "forged")).to be_empty
      expect(Swipe.count).to eq(1)
    end

    it "changes the verdict when the same anime is swiped again" do
      post swipes_path, params: { anime_id: anime.id, liked: false }

      expect { post swipes_path, params: { anime_id: anime.id, liked: true } }
        .not_to change(Swipe, :count)
      expect(Swipe.last.liked).to be(true)
    end

    it "answers not found for an unknown anime" do
      post swipes_path, params: { anime_id: 0, liked: true }

      expect(response).to have_http_status(:not_found)
    end

    it "refuses a swipe without a verdict" do
      expect { post swipes_path, params: { anime_id: anime.id } }.not_to change(Swipe, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /swipes asking for a Turbo Stream" do
    let(:anime) { create(:anime) }
    let(:turbo_stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

    it "replaces the progress with the share of the session already swiped" do
      post swipes_path,
           params: { anime_id: anime.id, liked: true, position: 8, total: 20 },
           headers: turbo_stream_headers

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include('<turbo-stream action="replace" target="deck-progress">')
      expect(response.body).to include("35 %")
    end

    it "refuses a position outside the deck" do
      post swipes_path,
           params: { anime_id: anime.id, liked: true, position: 26, total: 24 },
           headers: turbo_stream_headers

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "refuses a request without a position" do
      post swipes_path, params: { anime_id: anime.id, liked: true }, headers: turbo_stream_headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /swipes on the last card" do
    it "replaces the whole deck with the end of deck message" do
      post swipes_path,
           params: { anime_id: create(:anime).id, liked: true, position: 25, total: 24 },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.body).to include('<turbo-stream action="replace" target="swipe-deck">')
      expect(response.body).to include("Session terminée !")
      expect(response.body).to include(%(href="#{root_path}"))
      expect(response.body).to include(%(href="#{recommendations_path}"))
    end
  end

  describe "GET / for a returning visitor" do
    let!(:animes) { create_list(:anime, 3, cover_image_url: "https://img.test/cover.jpg") }

    def swipe(anime, liked: true)
      post swipes_path, params: { anime_id: anime.id, liked: liked }
    end

    it "does not offer the anime already swiped again" do
      swipe(animes.first)

      get root_path

      expect(response.body).not_to include(%(data-anime-id="#{animes.first.id}"))
      expect(response.body).to include(%(data-anime-id="#{animes.second.id}"))
      expect(response.body).to include(%(data-anime-id="#{animes.third.id}"))
    end

    it "also leaves out the anime that were passed" do
      swipe(animes.first, liked: false)

      get root_path

      expect(response.body).not_to include(%(data-anime-id="#{animes.first.id}"))
    end

    it "starts a new session over the remaining anime" do
      swipe(animes.first)

      get root_path

      expect(response.body).to include("0 %")
      expect(response.body).to include(%(data-swipe-deck-total-value="2"))
    end

    it "tells the visitor that every anime was seen" do
      animes.each { |anime| swipe(anime) }

      get root_path

      expect(response.body).to include("Tu as tout vu !")
      expect(response.body).not_to include("Le catalogue est vide")
    end

    it "gives the whole deck to a visitor with a forged cookie" do
      cookies[:taste_session] = "forged"

      get root_path

      animes.each { |anime| expect(response.body).to include(%(data-anime-id="#{anime.id}")) }
    end

    it "gives the whole deck back when the profile no longer exists" do
      swipe(animes.first)
      TasteProfile.destroy_all

      get root_path

      expect(response.body).to include(%(data-anime-id="#{animes.first.id}"))
    end

    it "does not create a profile just by looking at the deck" do
      expect { get root_path }.not_to change(TasteProfile, :count)
    end
  end

  describe "GET / dominant tastes" do
    let(:thriller) { create(:genre, name: "Thriller") }
    let(:liked) { create(:anime, genres: [ thriller ]) }

    before { create(:anime, cover_image_url: "https://img.test/cover.jpg") }

    it "shows the tastes a signed in person loves in the side panel" do
      user = create(:user)
      sign_in user
      user.create_taste_profile!.record_swipe(liked, liked: true)

      get root_path

      expect(document).to have_css("#taste-profile-panel [data-role='taste']", text: "Thriller")
    end

    it "shows the tastes of a visitor, found through the cookie" do
      post swipes_path, params: { anime_id: liked.id, liked: true, position: 1, total: 20 }

      get root_path

      expect(document).to have_css("#taste-profile-panel [data-role='taste']", text: "Thriller")
    end

    it "keeps the empty message while the person has not swiped" do
      get root_path

      expect(document).to have_text("Swipe quelques animes pour dessiner ton profil.")
      expect(document).to have_no_css("[data-role='taste']")
    end

    it "does not create a taste profile just to look" do
      expect { get root_path }.not_to change(TasteProfile, :count)
    end
  end

  describe "POST /swipes asking for a Turbo Stream, the taste panel" do
    let(:liked) { create(:anime, genres: [ create(:genre, name: "Thriller") ]) }
    let(:stream_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

    def swipe(position: 2, total: 20)
      post swipes_path, params: { anime_id: liked.id, liked: true, position: position, total: total },
                        headers: stream_headers
    end

    it "replaces the side panel with the tastes learned so far" do
      swipe

      expect(response.body).to include('target="taste-profile-panel"')
      expect(response.body).to include('data-role="taste"')
      expect(response.body).to include("Thriller")
    end

    it "offers a visitor to save the profile" do
      swipe

      expect(response.body).to include("Sauvegarder mon profil")
    end

    it "links a signed in person to the full profile" do
      sign_in create(:user)

      swipe

      expect(response.body).to include("Voir mon profil complet")
      expect(response.body).not_to include("Sauvegarder mon profil")
    end

    it "still replaces the progress" do
      swipe

      expect(response.body).to include('target="deck-progress"')
    end

    it "refreshes the panel together with the end of the deck on the last card" do
      swipe(position: 21)

      expect(response.body).to include('target="swipe-deck"')
      expect(response.body).to include('target="taste-profile-panel"')
    end
  end
end
