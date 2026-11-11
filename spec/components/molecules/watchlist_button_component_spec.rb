require "rails_helper"

RSpec.describe Molecules::WatchlistButtonComponent, type: :component do
  let(:anime) { create(:anime) }
  let(:member) { create(:user) }
  let(:routes) { Rails.application.routes.url_helpers }

  def render_button(member:, entry: nil)
    render_inline(described_class.new(anime: anime, member: member, entry: entry))
  end

  context "with a member who does not have the anime yet" do
    before { render_button(member: member) }

    it "posts to the watchlist from a form" do
      expect(page).to have_css("form[method='post'][action='#{routes.anime_watchlist_entry_path(anime)}']")
    end

    it "offers the addition with a primary button" do
      expect(page).to have_css("button.btn-na-primary[type='submit']", text: "+ Ajouter à ma watchlist")
    end
  end

  context "with a member who already has the anime" do
    before { render_button(member: member, entry: create(:watchlist_entry, user: member, anime: anime)) }

    it "says the anime is in the list and leads to the watchlist" do
      expect(page).to have_link("Dans ma watchlist", href: routes.watchlist_path)
    end

    it "offers no addition" do
      expect(page).to have_no_css("form")
      expect(page).to have_no_button
    end
  end

  context "with a visitor" do
    before { render_button(member: nil) }

    it "invites them to create an account" do
      expect(page).to have_link("Créer un compte pour ajouter à ma watchlist", href: routes.new_user_registration_path)
    end

    it "offers no addition" do
      expect(page).to have_no_css("form")
    end
  end
end
