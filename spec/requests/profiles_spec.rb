require "rails_helper"

RSpec.describe "Profile page", type: :request do
  describe "GET /profil" do
    let(:html) { Capybara.string(response.body) }

    context "as a visitor" do
      it "asks to sign in" do
        get profile_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in" do
      let(:user) { create(:user, username: "Mika", email: "mika@example.com") }

      before { sign_in user }

      it "succeeds" do
        get profile_path

        expect(response).to have_http_status(:ok)
      end

      it "names the user and shows the e-mail address" do
        get profile_path

        expect(html).to have_css("h1", text: "Mika")
        expect(html).to have_text("mika@example.com")
      end

      it "names the three stats" do
        get profile_path

        expect(html).to have_text("Cartes swipées")
        expect(html).to have_text("Likes")
        expect(html).to have_text("Dans la watchlist")
      end

      it "offers to keep swiping" do
        get profile_path

        expect(html).to have_link("Continuer à swiper", href: root_path)
      end

      it "offers to reset the taste profile after a confirmation" do
        get profile_path

        expect(html).to have_css("dialog#reset-profile form[action='#{reset_taste_profile_path}']", visible: :all)
      end

      context "with a taste profile" do
        let(:genre_weights) { { "Thriller" => 0.8, "Comedy" => -0.3 } }
        let(:tag_weights) { { "Mystery" => 0.5 } }
        let(:taste_profile) do
          create(:taste_profile, :with_user, user: user, genre_weights: genre_weights, tag_weights: tag_weights)
        end

        before do
          create_list(:swipe, 3, taste_profile: taste_profile, liked: true)
          create_list(:swipe, 2, taste_profile: taste_profile, liked: false)
          create_list(:watchlist_entry, 2, user: user)
        end

        it "counts the swipes, the likes and the watchlist" do
          get profile_path

          expect(html).to have_css("[data-stat=swipes]", exact_text: "5")
          expect(html).to have_css("[data-stat=likes]", exact_text: "3")
          expect(html).to have_css("[data-stat=watchlist]", exact_text: "2")
        end

        it "lists the genres and tags the user likes, not the ones avoided" do
          get profile_path

          expect(html).to have_css("[data-list=genres] li", text: "Thriller")
          expect(html).to have_no_css("[data-list=genres] li", text: "Comedy")
          expect(html).to have_css("[data-list=tags] li", text: "Mystery")
        end

        it "never shows the taste profile of another account" do
          create(:taste_profile, :with_user, genre_weights: { "Horror" => 0.9 })

          get profile_path

          expect(html).to have_no_text("Horror")
        end
      end

      context "without any taste profile yet" do
        it "shows zeros" do
          get profile_path

          expect(html).to have_css("[data-stat=swipes]", exact_text: "0")
          expect(html).to have_css("[data-stat=likes]", exact_text: "0")
          expect(html).to have_css("[data-stat=watchlist]", exact_text: "0")
        end

        it "creates no profile just by looking at the page" do
          expect { get profile_path }.not_to change(TasteProfile, :count)
        end
      end
    end
  end
end
