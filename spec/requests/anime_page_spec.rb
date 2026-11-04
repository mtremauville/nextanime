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

    it "links back to the recommendations" do
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
end
