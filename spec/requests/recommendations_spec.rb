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
        expect(page).to have_text("Aucune recommandation")
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
end
