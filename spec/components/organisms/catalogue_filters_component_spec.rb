require "rails_helper"

RSpec.describe Organisms::CatalogueFiltersComponent, type: :component do
  let(:genres) { [ build_stubbed(:genre, id: 3, name: "Action"), build_stubbed(:genre, id: 5, name: "Comédie") ] }
  let(:no_filter) { CatalogueFilters.from_params(nil) }

  def render_filters(filters: no_filter, genres: self.genres, search: nil)
    render_inline(described_class.new(action: "/catalogue", filters: filters, genres: genres, search: search))
  end

  it "is a landmark named after the filters" do
    render_filters

    expect(page).to have_css("aside[aria-label='Filtres'] h2", text: "Filtres")
  end

  it "sends the filters with a GET to the catalogue" do
    render_filters

    expect(page).to have_css("form[method='get'][action='/catalogue']")
  end

  it "offers the genres as a list of checkboxes" do
    render_filters

    expect(page).to have_css("fieldset legend", text: "Genres")
    expect(page).to have_css("input[type='checkbox'][name='genre_ids[]'][value='3']")
    expect(page).to have_field("Action", type: "checkbox")
    expect(page).to have_field("Comédie", type: "checkbox")
  end

  it "offers the formats with their names" do
    render_filters

    expect(page).to have_css("input[type='checkbox'][name='formats[]']", count: CatalogueFilters::FORMATS.size)
    expect(page).to have_field("Série", with: "tv")
    expect(page).to have_field("Film", with: "movie")
  end

  it "offers the statuses with their names" do
    render_filters

    expect(page).to have_css("input[type='checkbox'][name='statuses[]']", count: CatalogueFilters::STATUSES.size)
    expect(page).to have_field("Terminé", with: "finished")
    expect(page).to have_field("En cours de diffusion", with: "releasing")
    expect(page).to have_field("Pas encore diffusé", with: "not_yet_released")
  end

  it "offers the seasons, starting with all of them" do
    render_filters

    expect(page.all("select[name='season'] option").map(&:text)).to eq([ "Toutes les saisons", "Hiver", "Printemps", "Été", "Automne" ])
  end

  it "offers a first and a last year" do
    render_filters

    expect(page).to have_field("Depuis", type: "number")
    expect(page).to have_field("Jusqu'à", type: "number")
    expect(page).to have_css("input[name='year_from']")
    expect(page).to have_css("input[name='year_to']")
  end

  it "submits with a clear label" do
    render_filters

    expect(page).to have_button("Appliquer")
  end

  it "does not send the page, so that new filters start on the first page" do
    render_filters

    expect(page).to have_no_css("input[name='page']", visible: :all)
  end

  describe "with filters already chosen" do
    let(:chosen) do
      CatalogueFilters.new(genre_ids: [ 5 ], formats: %w[movie], statuses: %w[finished], season: "fall", year_from: 1990, year_to: 2005)
    end

    before { render_filters(filters: chosen) }

    it "checks the chosen genres, formats and statuses only" do
      expect(page).to have_checked_field("Comédie")
      expect(page).to have_unchecked_field("Action")
      expect(page).to have_checked_field("Film")
      expect(page).to have_unchecked_field("Série")
      expect(page).to have_checked_field("Terminé")
      expect(page).to have_unchecked_field("En cours de diffusion")
    end

    it "selects the chosen season" do
      expect(page).to have_select("Saison", selected: "Automne")
    end

    it "fills in the chosen years" do
      expect(page).to have_field("Depuis", with: "1990")
      expect(page).to have_field("Jusqu'à", with: "2005")
    end
  end

  describe "the search under way" do
    it "is kept in a hidden field, so that filtering does not erase it" do
      render_filters(search: "monster")

      expect(page).to have_css("input[type='hidden'][name='q'][value='monster']", visible: :all)
    end

    it "adds no field when there is no search" do
      render_filters(search: "")

      expect(page).to have_no_css("input[name='q']", visible: :all)
    end
  end

  it "leaves out the genres when there is none" do
    render_filters(genres: [])

    expect(page).to have_no_css("fieldset legend", text: "Genres")
    expect(page).to have_css("fieldset legend", text: "Format")
  end
end
