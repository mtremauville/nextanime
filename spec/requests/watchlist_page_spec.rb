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

  describe "a status without any entry" do
    let(:member) { create(:user) }
    let(:html) { Capybara.string(response.body) }

    before do
      sign_in member
      create(:watchlist_entry, user: member)
    end

    it "says so instead of showing an empty list" do
      get watchlist_path(status: "completed")

      expect(html).to have_text("Aucun anime avec ce statut pour le moment.")
      expect(html).to have_no_css("li.na-watch-row")
    end

    it "keeps the filter, to go back to the other entries" do
      get watchlist_path(status: "completed")

      expect(html).to have_link("Tous · 1", href: watchlist_path)
    end
  end

  describe "the progress buttons" do
    let(:member) { create(:user) }
    let(:html) { Capybara.string(response.body) }

    before { sign_in member }

    it "puts the two buttons on each row" do
      create(:watchlist_entry, :watching, user: member)
      create(:watchlist_entry, user: member)

      get watchlist_path

      expect(html).to have_css("li.na-watch-row .na-stepper", count: 2)
      expect(html).to have_css("li.na-watch-row .na-stepper__button", count: 4)
    end

    it "keeps the chosen filter when a button is pressed" do
      create(:watchlist_entry, :watching, user: member)

      get watchlist_path(status: "watching")

      expect(html).to have_css("form[class*='na-stepper__form'][action$='?status=watching']", count: 2)
    end
  end

  describe "the page refresh" do
    it "keeps the scroll position and morphs the page when the progress changes" do
      sign_in create(:user)

      get watchlist_path

      html = Capybara.string(response.body)
      expect(html).to have_css("meta[name='turbo-refresh-method'][content='morph']", visible: :all)
      expect(html).to have_css("meta[name='turbo-refresh-scroll'][content='preserve']", visible: :all)
    end
  end

  describe "the removal" do
    let(:member) { create(:user) }
    let(:html) { Capybara.string(response.body) }
    let!(:first_entry) { create(:watchlist_entry, :watching, user: member) }
    let!(:second_entry) { create(:watchlist_entry, user: member) }

    before { sign_in member }

    it "puts a confirmation on every row" do
      get watchlist_path

      [ first_entry, second_entry ].each do |entry|
        expect(html).to have_css(".na-watch-page__list dialog#remove-entry-#{entry.id}")
      end
      expect(html).to have_css(".na-watch-page__list button[data-action='confirm-modal#open'][aria-label^='Retirer']", count: 2)
    end

    it "keeps the current filter in the removal request" do
      get watchlist_path(status: "watching")

      expect(html).to have_css("dialog form[action='/watchlist/#{first_entry.id}?status=watching']")
    end
  end
end
