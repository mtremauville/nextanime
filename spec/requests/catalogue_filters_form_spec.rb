require "rails_helper"

RSpec.describe "Catalogue filters form", type: :request do
  def page_of(response)
    Capybara.string(response.body)
  end

  def filters_form
    page_of(response).find("aside[aria-label='Filtres'] form")
  end

  describe "GET /catalogue" do
    it "shows the filters next to the results" do
      get catalogue_path

      expect(page_of(response)).to have_css("aside[aria-label='Filtres'] form[method='get'][action='/catalogue']")
    end

    it "hides the filters on a phone, where a later story brings its own sheet" do
      get catalogue_path

      expect(page_of(response)).to have_css("div.d-none.d-md-block > aside[aria-label='Filtres']")
    end

    it "offers every genre, in alphabetical order" do
      drama = create(:genre, name: "Drame")
      action = create(:genre, name: "Action")

      get catalogue_path

      ids = filters_form.all("input[name='genre_ids[]']").map { |input| input[:value].to_i }

      expect(ids).to eq([ action.id, drama.id ])
    end

    it "checks the genres, formats and statuses that are chosen" do
      comedy = create(:genre, name: "Comédie")
      create(:genre, name: "Action")

      get catalogue_path, params: { genre_ids: [ comedy.id ], formats: %w[movie], statuses: %w[finished] }

      expect(filters_form).to have_checked_field("Comédie")
      expect(filters_form).to have_unchecked_field("Action")
      expect(filters_form).to have_checked_field("Film")
      expect(filters_form).to have_checked_field("Terminé")
      expect(filters_form).to have_unchecked_field("Série")
    end

    it "selects the chosen season and fills in the chosen years" do
      get catalogue_path, params: { season: "fall", year_from: "1990", year_to: "2005" }

      expect(filters_form).to have_select("Saison", selected: "Automne")
      expect(filters_form).to have_field("Année minimale", with: "1990")
      expect(filters_form).to have_field("Année maximale", with: "2005")
    end

    it "keeps the search under way in the filters form" do
      get catalogue_path, params: { q: "monster" }

      expect(filters_form).to have_css("input[type='hidden'][name='q'][value='monster']", visible: :all)
    end

    it "adds no search to the filters form when there is none" do
      get catalogue_path

      expect(filters_form).to have_no_css("input[name='q']", visible: :all)
    end

    it "keeps the filters in the search form" do
      get catalogue_path, params: { formats: %w[movie tv], season: "fall", genre_ids: [ 3 ] }

      search_form = page_of(response).find("form[role='search']")

      expect(search_form).to have_css("input[type='hidden'][name='formats[]']", count: 2, visible: :all)
      expect(search_form).to have_css("input[type='hidden'][name='season'][value='fall']", visible: :all)
      expect(search_form).to have_css("input[type='hidden'][name='genre_ids[]'][value='3']", visible: :all)
    end

    it "adds nothing to the search form when no filter is chosen" do
      get catalogue_path

      expect(page_of(response).find("form[role='search']")).to have_no_css("input[type='hidden']", visible: :all)
    end
  end

  describe "genre counts" do
    it "shows how many anime each genre has" do
      action = create(:genre, name: "Action")
      create(:genre, name: "Comédie")
      create_list(:anime, 2, genres: [ action ])

      get catalogue_path

      expect(filters_form).to have_css("label", text: "Action 2", normalize_ws: true)
      expect(filters_form).to have_css("label", text: "Comédie 0", normalize_ws: true)
    end

    it "counts the whole catalogue, whatever the filters" do
      action = create(:genre, name: "Action")
      create(:anime, format: :tv, genres: [ action ])
      create(:anime, format: :movie, genres: [ action ])

      get catalogue_path, params: { formats: %w[movie] }

      expect(filters_form).to have_css("label", text: "Action 2", normalize_ws: true)
    end
  end

  describe "the layout" do
    before { get catalogue_path }

    it "puts the search above the two columns, not inside them" do
      expect(page_of(response)).to have_css("form[role='search']")
      expect(page_of(response)).to have_no_css(".na-catalogue-layout form[role='search']")
    end

    it "keeps the filters and the results side by side" do
      expect(page_of(response)).to have_css(".na-catalogue-layout > .na-catalogue-layout__filters aside[aria-label='Filtres']")
      expect(page_of(response)).to have_css(".na-catalogue-layout > .na-catalogue-layout__results [data-role='catalogue-item']", count: 0)
    end
  end
end
