require "rails_helper"

RSpec.describe CatalogueStudios do
  let!(:mappa) { create(:studio, name: "MAPPA") }
  let!(:bones) { create(:studio, name: "Bones") }
  let!(:madhouse) { create(:studio, name: "Madhouse") }
  let!(:ghibli) { create(:studio, name: "Ghibli") }
  let!(:idle) { create(:studio, name: "Idle") }

  before do
    2.times { create(:anime, studios: [ mappa ]) }
    shared = create(:anime)
    create(:anime_studio, anime: shared, studio: mappa, main: true)
    create(:anime_studio, anime: shared, studio: bones)
    create(:anime, studios: [ bones, madhouse ])
    create(:anime, studios: [ madhouse, ghibli ])
  end

  def options_for(**given)
    described_class.new(**given).call.map { |option| [ option.name, option.count ] }
  end

  it "lists the studios with their anime, the most prolific first and by name among equals" do
    expect(options_for).to eq([ [ "MAPPA", 3 ], [ "Bones", 2 ], [ "Madhouse", 2 ], [ "Ghibli", 1 ] ])
  end

  it "counts the anime of a studio whether it is the main one or not" do
    expect(options_for.to_h).to include("MAPPA" => 3, "Bones" => 2)
  end

  it "leaves out a studio without anime" do
    expect(options_for.map(&:first)).not_to include("Idle")
  end

  it "gives the id of each studio, for its checkbox" do
    expect(described_class.new.call.first.id).to eq(mappa.id)
  end

  it "keeps the most prolific studios up to the limit" do
    expect(options_for(limit: 2)).to eq([ [ "MAPPA", 3 ], [ "Bones", 2 ] ])
  end

  it "keeps a selected studio that the limit would leave out" do
    expect(options_for(limit: 1, selected_ids: [ ghibli.id ])).to eq([ [ "MAPPA", 3 ], [ "Ghibli", 1 ] ])
  end

  it "lists a selected studio once when it is already among the first" do
    expect(options_for(limit: 2, selected_ids: [ mappa.id ])).to eq([ [ "MAPPA", 3 ], [ "Bones", 2 ] ])
  end

  it "ignores a selected id that is not a studio with anime" do
    expect(options_for(limit: 1, selected_ids: [ 0, idle.id ])).to eq([ [ "MAPPA", 3 ] ])
  end

  it "keeps the most prolific studios up to the default limit" do
    stub_const("CatalogueStudios::DEFAULT_LIMIT", 2)

    expect(options_for).to eq([ [ "MAPPA", 3 ], [ "Bones", 2 ] ])
  end
end
