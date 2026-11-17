require "rails_helper"

RSpec.describe CataloguePlatforms do
  let!(:crunchyroll) { create(:streaming_platform, name: "Crunchyroll") }
  let!(:netflix) { create(:streaming_platform, name: "Netflix") }
  let!(:disney) { create(:streaming_platform, name: "Disney Plus") }
  let!(:idle) { create(:streaming_platform, name: "Idle") }

  def offer(anime, platform, country_code: "FR", offer_type: "flatrate")
    create(:streaming_availability, anime: anime, streaming_platform: platform,
                                    country_code: country_code, offer_type: offer_type)
  end

  def options_for(country_code: "FR", **given)
    described_class.new(country_code: country_code, **given).call.map { |option| [ option.name, option.count ] }
  end

  before do
    2.times { offer(create(:anime), crunchyroll) }
    shared = create(:anime)
    offer(shared, crunchyroll)
    offer(shared, netflix)
    offer(shared, netflix, offer_type: "ads")
    offer(create(:anime), netflix)
    2.times { offer(create(:anime), disney) }
    offer(create(:anime), disney, country_code: "US")
  end

  it "lists the platforms of the country with their anime, the most offered first and by name among equals" do
    expect(options_for).to eq([ [ "Crunchyroll", 3 ], [ "Disney Plus", 2 ], [ "Netflix", 2 ] ])
  end

  it "counts an anime once, whatever the number of offers it has on a platform" do
    expect(options_for.to_h).to include("Netflix" => 2)
  end

  it "only looks at the offers of the given country" do
    expect(options_for(country_code: "US")).to eq([ [ "Disney Plus", 1 ] ])
  end

  it "leaves out a platform without offer in the country" do
    expect(options_for.map(&:first)).not_to include("Idle")
  end

  it "lists nothing for a country without offer" do
    expect(options_for(country_code: "CH")).to eq([])
  end

  it "gives the id of each platform, for its checkbox" do
    expect(described_class.new(country_code: "FR").call.first.id).to eq(crunchyroll.id)
  end

  it "keeps a selected platform that has no offer in the country, with no anime" do
    expect(options_for(selected_ids: [ idle.id ])).to eq([ [ "Crunchyroll", 3 ], [ "Disney Plus", 2 ], [ "Netflix", 2 ], [ "Idle", 0 ] ])
  end

  it "does not list a selected platform twice" do
    expect(options_for(selected_ids: [ netflix.id ]).count { |name, _count| name == "Netflix" }).to eq(1)
  end

  it "ignores a selected platform that does not exist" do
    expect(options_for(selected_ids: [ 0 ])).to eq([ [ "Crunchyroll", 3 ], [ "Disney Plus", 2 ], [ "Netflix", 2 ] ])
  end
end
