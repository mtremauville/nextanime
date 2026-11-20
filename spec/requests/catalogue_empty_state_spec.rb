require "rails_helper"

RSpec.describe "Catalogue without result", type: :request do
  def page_of(response)
    Capybara.string(response.body)
  end

  describe "GET /catalogue" do
    it "says that nothing matches and offers the whole catalogue" do
      create(:anime, title_romaji: "Monster")

      get catalogue_path, params: { q: "zzz" }

      expect(page_of(response)).to have_css("h2", text: "Aucun anime ne correspond")
      expect(page_of(response)).to have_link("Voir tout le catalogue", href: catalogue_path)
    end

    it "shows neither the grid nor the load more button" do
      get catalogue_path, params: { q: "zzz" }

      expect(page_of(response)).to have_no_css("#catalogue-grid")
      expect(page_of(response)).to have_no_text("Voir plus")
    end

    it "keeps the chips, so that a filter can be removed from there" do
      create(:anime, title_romaji: "Series", format: :tv)

      get catalogue_path, params: { formats: %w[movie] }

      expect(page_of(response)).to have_link("Retirer le filtre Film")
    end

    it "does not show the empty state when there is something to show" do
      create(:anime, title_romaji: "Monster")

      get catalogue_path

      expect(page_of(response)).to have_no_text("Aucun anime ne correspond")
      expect(page_of(response)).to have_css("#catalogue-grid")
    end
  end
end
