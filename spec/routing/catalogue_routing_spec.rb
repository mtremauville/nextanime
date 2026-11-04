require "rails_helper"

RSpec.describe "Catalogue routing", type: :routing do
  it "routes /catalogue to the index of the animes" do
    expect(get: "/catalogue").to route_to("animes#index")
  end

  it "keeps the page number as a parameter" do
    expect(get: "/catalogue?page=2").to route_to("animes#index", page: "2")
  end

  it "names the route catalogue_path" do
    expect(catalogue_path).to eq("/catalogue")
  end
end
