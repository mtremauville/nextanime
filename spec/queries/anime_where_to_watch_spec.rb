require "rails_helper"

RSpec.describe AnimeWhereToWatch do
  subject(:where_to_watch) { described_class.new(anime: anime, country_code: "FR") }

  let(:anime) { create(:anime) }
  let(:crunchyroll) { create(:streaming_platform, name: "Crunchyroll", slug: "crunchyroll") }
  let(:netflix) { create(:streaming_platform, name: "Netflix", slug: "netflix") }

  def offer(platform, offer_type: :flatrate, country_code: "FR")
    create(:streaming_availability, anime: anime, streaming_platform: platform, offer_type: offer_type, country_code: country_code)
  end

  describe "#entries" do
    it "lists the offers of the country only" do
      offer(crunchyroll)
      offer(netflix, country_code: "BE")

      expect(where_to_watch.entries.map(&:platform)).to eq([ crunchyroll ])
    end

    it "is empty when the country has no offer" do
      expect(where_to_watch.entries).to eq([])
    end

    it "puts the subscriptions first, then the free offers, then the free offers with ads" do
      offer(netflix, offer_type: :ads)
      offer(crunchyroll, offer_type: :free)
      offer(netflix)

      expect(where_to_watch.entries.map { |entry| [ entry.platform.name, entry.offer_type ] })
        .to eq([ %w[Netflix flatrate], %w[Crunchyroll free], %w[Netflix ads] ])
    end

    it "sorts the platforms of the same type of offer by name" do
      offer(netflix)
      offer(crunchyroll)

      expect(where_to_watch.entries.map { |entry| entry.platform.name }).to eq(%w[Crunchyroll Netflix])
    end

    it "links to the streaming link of AniList when the platform has one" do
      offer(crunchyroll)
      create(:streaming_link, anime: anime, streaming_platform: crunchyroll, url: "https://www.crunchyroll.com/series/ABC")
      create(:tmdb_match, anime: anime, watch_links: { "FR" => "https://www.themoviedb.org/tv/1/watch?locale=FR" })

      expect(where_to_watch.entries.first.url).to eq("https://www.crunchyroll.com/series/ABC")
    end

    it "links to the first streaming link when the platform has several" do
      offer(crunchyroll)
      create(:streaming_link, anime: anime, streaming_platform: crunchyroll, url: "https://www.crunchyroll.com/series/FIRST")
      create(:streaming_link, anime: anime, streaming_platform: crunchyroll, url: "https://www.crunchyroll.com/series/SECOND")

      expect(where_to_watch.entries.first.url).to eq("https://www.crunchyroll.com/series/FIRST")
    end

    it "links to the watch page of TMDB for the country otherwise" do
      offer(netflix)
      create(:tmdb_match, anime: anime, watch_links: {
        "FR" => "https://www.themoviedb.org/tv/1/watch?locale=FR", "BE" => "https://www.themoviedb.org/tv/1/watch?locale=BE"
      })

      expect(where_to_watch.entries.first.url).to eq("https://www.themoviedb.org/tv/1/watch?locale=FR")
    end

    it "has no link when nothing gives one" do
      offer(netflix)

      expect(where_to_watch.entries.first.url).to be_nil
    end
  end

  describe "#known?" do
    it "is true when the anime is matched with TMDB" do
      create(:tmdb_match, anime: anime)

      expect(where_to_watch).to be_known
    end

    it "is false when TMDB does not know the anime" do
      create(:tmdb_match, :unmatched, anime: anime)

      expect(where_to_watch).not_to be_known
    end

    it "is false when the anime was never looked up" do
      expect(where_to_watch).not_to be_known
    end
  end
end
