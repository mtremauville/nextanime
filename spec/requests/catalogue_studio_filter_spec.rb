require "rails_helper"

RSpec.describe "Catalogue studio filter", type: :request do
  let!(:mappa) { create(:studio, name: "MAPPA") }

  before { 2.times { create(:anime, studios: [ mappa ]) } }

  def html = Capybara.string(response.body)

  describe "GET /catalogue" do
    it "offers the studios of the catalogue in the column, with their number of anime" do
      get catalogue_path

      expect(html).to have_css(".na-catalogue-layout__filters input[name='studio_ids[]'][value='#{mappa.id}']")
      expect(html).to have_css(".na-catalogue-layout__filters [data-role='count']", text: "2")
    end

    it "checks the chosen studio in the column and in the sheet" do
      get catalogue_path, params: { studio_ids: [ mappa.id ] }

      expect(html).to have_css("input[name='studio_ids[]'][value='#{mappa.id}'][checked]", visible: :all, count: 2)
    end

    it "offers the studios in the sheet too, without counts" do
      get catalogue_path

      expect(html).to have_css("dialog input[name='studio_ids[]']", visible: :all, count: 1)
      expect(html).to have_no_css("dialog [data-role='count']", visible: :all)
    end

    it "gives the studios of the column and of the sheet different ids" do
      get catalogue_path

      ids = html.all("input[name='studio_ids[]']", visible: :all).map { |input| input[:id] }

      expect([ ids.size, ids.uniq.size ]).to eq([ 2, 2 ])
    end
  end
end
