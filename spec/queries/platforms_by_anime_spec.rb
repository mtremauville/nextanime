require "rails_helper"

RSpec.describe PlatformsByAnime do
  subject(:platforms_by_anime) { described_class.new(animes: animes, country_code: "FR").call }

  let(:animes) { create_list(:anime, 2) }
  let(:anime) { animes.first }
  let(:other_anime) { animes.second }
  let(:crunchyroll) { create(:streaming_platform, name: "Crunchyroll", slug: "crunchyroll") }
  let(:netflix) { create(:streaming_platform, name: "Netflix", slug: "netflix") }
  let(:alpha) { create(:streaming_platform, name: "Alpha", slug: "alpha") }
  let(:zeta) { create(:streaming_platform, name: "Zeta", slug: "zeta") }

  def offer(an_anime, platform, offer_type: :flatrate, country_code: "FR")
    create(:streaming_availability, anime: an_anime, streaming_platform: platform, offer_type: offer_type, country_code: country_code)
  end

  def count_queries(&block)
    count = 0
    counter = ->(_name, _start, _finish, _id, payload) { count += 1 unless payload[:name] == "SCHEMA" }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end

  it "lists the platforms of each anime" do
    offer(anime, crunchyroll)
    offer(other_anime, netflix)

    expect(platforms_by_anime[anime.id]).to eq([ crunchyroll ])
    expect(platforms_by_anime[other_anime.id]).to eq([ netflix ])
  end

  it "keeps the offers of the country only" do
    offer(anime, crunchyroll)
    offer(anime, netflix, country_code: "BE")

    expect(platforms_by_anime[anime.id]).to eq([ crunchyroll ])
  end

  it "lists a platform once, whatever the number of its offers" do
    offer(anime, netflix)
    offer(anime, netflix, offer_type: :ads)

    expect(platforms_by_anime[anime.id]).to eq([ netflix ])
  end

  it "puts the best offers first (subscription, free, free with ads), then the platforms by name" do
    offer(anime, netflix, offer_type: :ads)
    offer(anime, crunchyroll, offer_type: :free)
    offer(anime, zeta)
    offer(anime, alpha)

    expect(platforms_by_anime[anime.id]).to eq([ alpha, zeta, crunchyroll, netflix ])
  end

  it "gives an empty list to an anime without any offer" do
    offer(anime, netflix)

    expect(platforms_by_anime[other_anime.id]).to eq([])
  end

  it "gives an empty list to an anime that is not on the page" do
    expect(platforms_by_anime[0]).to eq([])
  end

  it "loads the platforms of the whole page in two queries, whatever the number of anime" do
    animes.each { |listed| offer(listed, netflix) && offer(listed, crunchyroll) }

    queries = count_queries { platforms_by_anime.values.flatten.map(&:name) }

    expect(queries).to eq(2)
  end
end
