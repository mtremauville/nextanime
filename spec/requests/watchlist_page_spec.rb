require "rails_helper"

RSpec.describe "The watchlist page", type: :request do
  context "when nobody is signed in" do
    it "sends the visitor to the sign in page" do
      get watchlist_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when a member is signed in" do
    before { sign_in create(:user) }

    it "shows the page" do
      get watchlist_path

      expect(response).to have_http_status(:ok)
    end

    it "ignores a status that does not exist" do
      get watchlist_path, params: { status: "dropped" }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "its content" do
    let(:member) { create(:user) }
    let(:html) { Capybara.string(response.body) }

    before { sign_in member }

    def query_count
      count = 0
      counter = ->(*, payload) { count += 1 unless payload[:name] == "SCHEMA" || payload[:cached] }
      ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { yield }
      count
    end

    context "without any entry" do
      it "invites the member to find something to watch" do
        get watchlist_path

        expect(html).to have_text("Ta watchlist est vide")
        expect(html).to have_link("Parcourir le catalogue", href: catalogue_path)
      end
    end

    context "with entries" do
      let!(:to_watch) { create(:watchlist_entry, user: member) }
      let!(:being_watched) do
        Array.new(2) { create(:watchlist_entry, :watching, user: member, anime: create(:anime, episodes: 12)) }
      end

      it "is titled after the watchlist" do
        get watchlist_path

        expect(html).to have_css("main h1", text: "Ma watchlist")
      end

      it "counts the entries of each status" do
        get watchlist_path

        expect(html).to have_css("[data-stat=plan_to_watch]", text: "1")
        expect(html).to have_css("[data-stat=watching]", text: "2")
        expect(html).to have_css("[data-stat=completed]", text: "0")
      end

      it "lists every entry of the member" do
        get watchlist_path

        expect(html).to have_css("li.na-watch-row", count: 3)
        expect(html).to have_link(to_watch.anime.display_title)
      end

      it "does not list the entries of other members" do
        other_entry = create(:watchlist_entry)

        get watchlist_path

        expect(html).to have_no_text(other_entry.anime.display_title)
      end

      it "offers a filter by status with the number of entries of each" do
        get watchlist_path

        expect(html).to have_css("a.na-result-filter__choice.is-current", text: "Tous · 3", count: 1)
        expect(html).to have_link("À voir · 1", href: watchlist_path(status: "plan_to_watch"))
        expect(html).to have_link("En cours · 2", href: watchlist_path(status: "watching"))
        expect(html).to have_link("Terminés · 0", href: watchlist_path(status: "completed"))
      end

      it "keeps only the entries of the chosen status" do
        get watchlist_path(status: "watching")

        expect(html).to have_css("li.na-watch-row", count: 2)
        expect(html).to have_css("a.na-result-filter__choice.is-current", text: "En cours · 2", count: 1)
      end

      it "lists everything again for a status that does not exist" do
        get watchlist_path(status: "dropped")

        expect(html).to have_css("li.na-watch-row", count: 3)
        expect(html).to have_css("a.na-result-filter__choice.is-current", text: "Tous · 3", count: 1)
      end

      it "sums up the overall progress and where to resume" do
        get watchlist_path

        expect(html).to have_text("Avancement global")
        expect(html).to have_css(".na-watch-summary__card--resume", text: "Reprendre")
      end

      it "does not query more for more entries" do
        get watchlist_path
        few = query_count { get watchlist_path }
        4.times { create(:watchlist_entry, :watching, user: member) }
        many = query_count { get watchlist_path }

        expect(many).to eq(few)
      end
    end
  end
end
