require "rails_helper"

RSpec.describe "Catalogue sort form", type: :request do
  def page_of(response)
    Capybara.string(response.body)
  end

  def sort_form
    page_of(response).find(".na-catalogue-layout__results form.na-sort")
  end

  def option_names(form)
    form.all("select option").map(&:text)
  end

  describe "GET /catalogue for a visitor" do
    it "offers the sort above the results" do
      get catalogue_path

      expect(sort_form).to have_select("Trier par")
    end

    it "selects the popularity by default" do
      get catalogue_path

      expect(sort_form).to have_select("Trier par", selected: "Popularité")
    end

    it "does not offer the match, which cannot be told" do
      get catalogue_path

      expect(option_names(sort_form)).not_to include("Meilleur match")
    end

    it "selects the asked sort" do
      get catalogue_path, params: { sort: "score" }

      expect(sort_form).to have_select("Trier par", selected: "Note")
    end

    it "selects the popularity when the match is asked but cannot be told" do
      get catalogue_path, params: { sort: "match" }

      expect(sort_form).to have_select("Trier par", selected: "Popularité")
    end

    it "carries the search and the filters" do
      get catalogue_path, params: { q: "monster", formats: %w[tv], season: "fall" }

      expect(sort_form).to have_css("input[type='hidden'][name='q'][value='monster']", visible: :all)
      expect(sort_form).to have_css("input[type='hidden'][name='formats[]'][value='tv']", visible: :all)
      expect(sort_form).to have_css("input[type='hidden'][name='season'][value='fall']", visible: :all)
    end

    it "carries neither the page nor the sort itself, which the list sends" do
      get catalogue_path, params: { page: 1, sort: "score" }

      expect(sort_form).to have_no_css("input[name='page']", visible: :all)
      expect(sort_form).to have_no_css("input[type='hidden'][name='sort']", visible: :all)
    end
  end

  describe "GET /catalogue for a person who has liked something" do
    before do
      user = create(:user)
      sign_in user
      user.create_taste_profile!.record_swipe(create(:anime), liked: true)
    end

    it "offers the match and selects it by default" do
      get catalogue_path

      expect(sort_form).to have_select("Trier par", selected: "Meilleur match")
    end

    it "selects the asked sort" do
      get catalogue_path, params: { sort: "recent" }

      expect(sort_form).to have_select("Trier par", selected: "Plus récents")
    end
  end

  describe "the sort under way" do
    it "is kept by the search form" do
      get catalogue_path, params: { sort: "score" }

      search_form = page_of(response).find("form[role='search']")

      expect(search_form).to have_css("input[type='hidden'][name='sort'][value='score']", visible: :all)
    end

    it "is kept by the filters form" do
      get catalogue_path, params: { sort: "score" }

      filters_form = page_of(response).find("aside[aria-label='Filtres'] form")

      expect(filters_form).to have_css("input[type='hidden'][name='sort'][value='score']", visible: :all)
    end

    it "is not written in the forms when none was asked" do
      get catalogue_path

      expect(page_of(response)).to have_no_css("form[role='search'] input[name='sort'], aside form input[name='sort']", visible: :all)
    end
  end
end
