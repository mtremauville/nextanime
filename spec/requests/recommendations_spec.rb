require "rails_helper"

RSpec.describe "Recommendations", type: :request do
  let(:thriller) { create(:genre, name: "Thriller") }
  let(:cooking) { create(:genre, name: "Cooking") }
  let(:user) { create(:user) }

  def page
    Capybara.string(response.body)
  end

  def cards
    page.all("[data-role='recommendation']")
  end

  def card_titles
    cards.map(&:text)
  end

  describe "GET /recos" do
    context "without any swipe" do
      it "invites to swipe" do
        get recommendations_path

        expect(response).to have_http_status(:ok)
        expect(page).to have_text("Swipe quelques animes")
        expect(page).to have_link(href: root_path)
      end

      it "does not create a taste profile just to look" do
        expect { get recommendations_path }.not_to change(TasteProfile, :count)
      end
    end

    context "with passes only" do
      it "invites to swipe" do
        sign_in user
        user.create_taste_profile!.record_swipe(create(:anime), liked: false)

        get recommendations_path

        expect(page).to have_text("Swipe quelques animes")
        expect(cards).to be_empty
      end
    end

    context "with a like" do
      let!(:liked) { create(:anime, genres: [ thriller ], format: :tv) }
      let!(:close) { create(:anime, genres: [ thriller ], format: :tv) }
      let!(:neutral) { create(:anime, genres: [ cooking ], format: :movie) }

      before do
        sign_in user
        user.create_taste_profile!.record_swipe(liked, liked: true)
      end

      it "ranks the anime by match, the closest first" do
        get recommendations_path

        expect(card_titles).to match([ a_string_including(close.display_title), a_string_including(neutral.display_title) ])
      end

      it "shows the match as a percentage" do
        get recommendations_path

        expect(cards.first.text).to match(/67\s?%/)
        expect(cards.last.text).to match(/50\s?%/)
      end

      it "leaves out the anime already swiped" do
        get recommendations_path

        expect(card_titles.join).not_to include(liked.display_title)
      end

      it "keeps the recommendations in the database" do
        get recommendations_path

        expect(user.taste_profile.recommendations.count).to eq(2)
      end

      it "does not compute them again while the profile is unchanged" do
        get recommendations_path

        expect { get recommendations_path }.not_to change { user.taste_profile.recommendations.maximum(:updated_at) }
      end

      it "says so when nothing is left to recommend" do
        user.taste_profile.record_swipe(close, liked: true)
        user.taste_profile.record_swipe(neutral, liked: false)

        get recommendations_path

        expect(cards).to be_empty
        expect(page).to have_text("Tu as tout swipé")
      end

      it "only shows the best ones" do
        stub_const("RecommendationsController::DISPLAYED", 1)

        get recommendations_path

        expect(card_titles).to match([ a_string_including(close.display_title) ])
      end

      it "keeps the series with kind=series" do
        get recommendations_path, params: { kind: "series" }

        expect(card_titles).to match([ a_string_including(close.display_title) ])
      end

      it "keeps the movies with kind=movies" do
        get recommendations_path, params: { kind: "movies" }

        expect(card_titles).to match([ a_string_including(neutral.display_title) ])
      end

      it "shows everything for an unknown kind" do
        get recommendations_path, params: { kind: "whatever" }

        expect(cards.size).to eq(2)
      end
    end

    context "as a visitor who swiped" do
      it "uses the profile attached to the cookie" do
        liked = create(:anime, genres: [ thriller ])
        other = create(:anime, genres: [ thriller ])
        post swipes_path, params: { anime_id: liked.id, liked: true, position: 1, total: 24 }

        get recommendations_path

        expect(card_titles).to match([ a_string_including(other.display_title) ])
      end
    end
  end

  describe "GET /recos, the page as a whole" do
    let!(:liked) { create(:anime, genres: [ thriller ], format: :tv) }
    let!(:series) { create(:anime, genres: [ thriller ], format: :tv) }
    let!(:movie) { create(:anime, genres: [ thriller ], format: :movie) }

    before do
      sign_in user
      user.create_taste_profile!.record_swipe(liked, liked: true)
    end

    it "names the strongest genres of the taste in the header" do
      get recommendations_path

      expect(page).to have_css(".na-recos-header span.na-tag--cyan", text: "Thriller")
    end

    it "links to the profile of a signed in person" do
      get recommendations_path

      expect(page).to have_link("Ton profil", href: profile_path)
    end

    it "offers the formats, all of them being shown at first" do
      get recommendations_path

      expect(page).to have_css("[role='group'][aria-label='Filtrer par format'] a[aria-current='true']", text: "Tous")
      expect(page).to have_link("Séries", href: recommendations_path(kind: "series"))
      expect(page).to have_link("Films", href: recommendations_path(kind: "movies"))
    end

    it "marks the chosen format" do
      get recommendations_path, params: { kind: "movies" }

      expect(page).to have_css("a[aria-current='true']", text: "Films")
    end

    it "counts the results" do
      get recommendations_path

      expect(page).to have_text("2 résultats")
    end

    it "counts a single result in the singular" do
      get recommendations_path, params: { kind: "movies" }

      expect(page).to have_text(/1 résultat(?!s)/)
    end

    it "keeps the filter when no anime has the chosen format" do
      user.taste_profile.record_swipe(series, liked: false)

      get recommendations_path, params: { kind: "series" }

      expect(page).to have_text("Aucune recommandation")
      expect(page).to have_link("Tous", href: recommendations_path)
    end

    it "has no link to the profile for a visitor" do
      sign_out user
      post swipes_path, params: { anime_id: liked.id, liked: true, position: 1, total: 24 }

      get recommendations_path

      expect(page).to have_no_link("Ton profil")
    end
  end

  describe "GET /recos once every anime has been swiped" do
    let!(:liked) { create(:anime, genres: [ thriller ]) }
    let!(:passed) { create(:anime, genres: [ cooking ]) }

    before do
      sign_in user
      profile = user.create_taste_profile!
      profile.record_swipe(liked, liked: true)
      profile.record_swipe(passed, liked: false)
    end

    it "tells that nothing is left to recommend" do
      get recommendations_path

      expect(page).to have_text("Tu as tout swipé")
      expect(cards).to be_empty
    end

    it "sends a signed in person to the profile" do
      get recommendations_path

      expect(page).to have_link("Voir mon profil", href: profile_path)
    end

    it "offers a visitor to create an account" do
      sign_out user
      post swipes_path, params: { anime_id: liked.id, liked: true }
      post swipes_path, params: { anime_id: passed.id, liked: false }

      get recommendations_path

      expect(page).to have_text("Tu as tout swipé")
      expect(page).to have_link("Créer un compte pour garder ton profil", href: new_user_registration_path)
    end

    it "keeps the message of the format when a format is chosen" do
      get recommendations_path, params: { kind: "series" }

      expect(page).to have_no_text("Tu as tout swipé")
      expect(page).to have_text("Aucune recommandation")
    end
  end

  describe "GET /recos explanation of the match" do
    let(:mind_games) { create(:tag, name: "Mind Games") }
    let(:liked) { create(:anime, genres: [ thriller ]) }
    let!(:candidates) do
      Array.new(3) do |index|
        create(:anime, title_romaji: "Candidate #{index}", title_english: nil, genres: [ thriller ]).tap do |anime|
          create(:anime_tag, anime: anime, tag: mind_games, rank: 70)
        end
      end
    end

    def tag_query_count
      count = 0
      counter = lambda do |*, payload|
        count += 1 if payload[:sql].match?(/FROM "(anime_tags|tags)"/)
      end
      ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { yield }
      count
    end

    before do
      create(:anime_tag, anime: liked, tag: mind_games, rank: 80)
      sign_in user
      user.create_taste_profile!.record_swipe(liked, liked: true)
    end

    it "tells why each anime fits, from the tags and genres in common" do
      get recommendations_path

      expect(cards.size).to eq(3)
      expect(page).to have_css(".na-poster-card__reason", text: "Parce que tu aimes Mind Games et Thriller.", count: 3)
    end

    it "loads the tags of all the recommendations at once" do
      get recommendations_path

      expect(tag_query_count { get recommendations_path }).to be <= 2
    end
  end
end
