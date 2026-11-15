require "rails_helper"

RSpec.describe AnimeWhereToWatch do
  subject(:where_to_watch) { described_class.new(anime: anime, country_code: "FR") }

  let(:anime) { create(:anime) }
  let(:crunchyroll) { create(:streaming_platform, name: "Crunchyroll", slug: "crunchyroll") }
  let(:netflix) { create(:streaming_platform, name: "Netflix", slug: "netflix") }
  let(:unlisted) { create(:streaming_platform, name: "Unlisted platform", slug: "unlisted-platform") }
  let(:sooner) { create(:streaming_platform, name: "Sooner", slug: "sooner") }

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

    it "gathers the offers of a platform in one entry, the best offer first" do
      offer(netflix, offer_type: :ads)
      offer(netflix)

      expect(where_to_watch.entries.map { |entry| [ entry.platform.name, entry.offer_types ] })
        .to eq([ [ "Netflix", %w[flatrate ads] ] ])
    end

    it "puts the platforms with the best offer first: subscription, free, free with ads" do
      offer(crunchyroll, offer_type: :free)
      offer(netflix, offer_type: :ads)
      offer(unlisted)

      expect(where_to_watch.entries.map { |entry| entry.platform.name })
        .to eq([ "Unlisted platform", "Crunchyroll", "Netflix" ])
    end

    it "sorts the platforms with the same best offer by name" do
      offer(netflix)
      offer(crunchyroll)

      expect(where_to_watch.entries.map { |entry| entry.platform.name }).to eq(%w[Crunchyroll Netflix])
    end

    it "links to the streaming link of AniList when the platform has one" do
      offer(crunchyroll)
      create(:streaming_link, anime: anime, streaming_platform: crunchyroll, url: "https://www.crunchyroll.com/series/ABC")

      expect(where_to_watch.entries.first.url).to eq("https://www.crunchyroll.com/series/ABC")
    end

    it "links to the first streaming link when the platform has several" do
      offer(crunchyroll)
      create(:streaming_link, anime: anime, streaming_platform: crunchyroll, url: "https://www.crunchyroll.com/series/FIRST")
      create(:streaming_link, anime: anime, streaming_platform: crunchyroll, url: "https://www.crunchyroll.com/series/SECOND")

      expect(where_to_watch.entries.first.url).to eq("https://www.crunchyroll.com/series/FIRST")
    end

    it "links to the home page of the platform when AniList gives no link, never to TMDB" do
      offer(sooner)
      create(:tmdb_match, anime: anime, watch_links: { "FR" => "https://www.themoviedb.org/tv/1/watch?locale=FR" })

      expect(where_to_watch.entries.first.url).to eq("https://www.sooner.be")
    end

    context "when AniList gives no link and the platform has a search" do
      let(:anime) { create(:anime, title_english: "Frieren Season 2") }

      it "searches the title of the series, without its season" do
        offer(netflix)

        expect(where_to_watch.entries.first.url).to eq("https://www.netflix.com/search?q=Frieren")
      end
    end

    it "has no link when the platform has neither a streaming link nor a home page" do
      offer(unlisted)

      expect(where_to_watch.entries.first.url).to be_nil
    end
  end

  describe "#tmdb_page_url" do
    it "gives the watch page of TMDB for the country" do
      create(:tmdb_match, anime: anime, watch_links: {
        "FR" => "https://www.themoviedb.org/tv/1/watch?locale=FR", "BE" => "https://www.themoviedb.org/tv/1/watch?locale=BE"
      })

      expect(where_to_watch.tmdb_page_url).to eq("https://www.themoviedb.org/tv/1/watch?locale=FR")
    end

    it "is nil when TMDB has no watch page for the country" do
      create(:tmdb_match, anime: anime, watch_links: {})

      expect(where_to_watch.tmdb_page_url).to be_nil
    end

    it "is nil when the anime was never looked up" do
      expect(where_to_watch.tmdb_page_url).to be_nil
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
