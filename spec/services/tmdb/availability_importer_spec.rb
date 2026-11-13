require "rails_helper"

RSpec.describe Tmdb::AvailabilityImporter do
  subject(:importer) { described_class.new(client: client, linker: linker) }

  let(:client) { instance_double(Tmdb::Client, watch_providers: providers) }
  let(:linker) { instance_double(Tmdb::AnimeLinker) }
  let(:providers) { JSON.parse(file_fixture("tmdb/watch_providers.json").read).fetch("results") }
  let(:anime) { create(:anime) }
  let(:tmdb_match) { create(:tmdb_match, anime: anime, tmdb_id: 209_867, media_type: :tv) }

  before { allow(linker).to receive(:link).with(anime).and_return(tmdb_match) }

  def offers
    anime.streaming_availabilities.includes(:streaming_platform).map do |availability|
      [ availability.country_code, availability.streaming_platform.name, availability.offer_type ]
    end
  end

  def provider(id, name)
    { "provider_id" => id, "provider_name" => name, "logo_path" => "/logo.jpg", "display_priority" => 1 }
  end

  describe "#import" do
    it "asks TMDB for the providers of the matched title" do
      importer.import(anime)

      expect(client).to have_received(:watch_providers).with(media_type: "tv", tmdb_id: 209_867)
    end

    it "returns the match of the anime" do
      expect(importer.import(anime)).to eq(tmdb_match)
    end

    it "stores the subscription offers by country and ignores the purchases" do
      importer.import(anime)

      expect(offers).to contain_exactly(
        %w[FR Crunchyroll flatrate], %w[FR ADN flatrate], %w[US Crunchyroll flatrate]
      )
    end

    it "ignores the countries that are not supported" do
      allow(client).to receive(:watch_providers).and_return(providers.merge("JP" => { "flatrate" => [ provider(283, "Crunchyroll") ] }))

      importer.import(anime)

      expect(anime.streaming_availabilities.pluck(:country_code)).not_to include("JP")
    end

    it "keeps the free and the ad-supported offers" do
      allow(client).to receive(:watch_providers).and_return(
        "FR" => { "free" => [ provider(73, "Tubi TV") ], "ads" => [ provider(300, "Pluto TV") ], "rent" => [ provider(2, "Apple TV") ] }
      )

      importer.import(anime)

      expect(offers).to contain_exactly(%w[FR Tubi\ TV free], [ "FR", "Pluto TV", "ads" ])
    end

    it "brings the variants of a platform back to the platform" do
      allow(client).to receive(:watch_providers).and_return(
        "FR" => { "flatrate" => [ provider(8, "Netflix"), provider(1796, "Netflix Standard with Ads") ] }
      )

      importer.import(anime)

      expect(offers).to eq([ %w[FR Netflix flatrate] ])
      expect(StreamingPlatform.where(slug: "netflix").count).to eq(1)
    end

    it "reuses the platform that AniList already gave" do
      anilist_platform = create(:streaming_platform, name: "Crunchyroll", slug: "crunchyroll")

      importer.import(anime)

      expect(StreamingPlatform.where(slug: "crunchyroll")).to contain_exactly(anilist_platform)
      expect(anilist_platform.reload.tmdb_provider_id).to eq(283)
    end

    it "creates the platform that AniList did not know" do
      importer.import(anime)

      expect(StreamingPlatform.find_by(slug: "adn")).to have_attributes(name: "ADN", tmdb_provider_id: 415)
    end

    it "does not take the id of a variant for the id of the platform" do
      allow(client).to receive(:watch_providers).and_return(
        "FR" => { "flatrate" => [ provider(1796, "Netflix Standard with Ads") ] }
      )

      importer.import(anime)

      expect(StreamingPlatform.find_by(slug: "netflix").tmdb_provider_id).to be_nil
    end

    it "does not duplicate the offers when the anime is imported again" do
      importer.import(anime)

      expect { importer.import(anime) }.not_to change(StreamingAvailability, :count)
    end

    it "drops the offers that TMDB no longer lists" do
      importer.import(anime)
      allow(client).to receive(:watch_providers).and_return(providers.slice("US"))

      importer.import(anime)

      expect(offers).to eq([ %w[US Crunchyroll flatrate] ])
    end

    context "when no TMDB title was found for the anime" do
      let(:tmdb_match) { create(:tmdb_match, :unmatched, anime: anime) }

      it "does not ask TMDB for any provider" do
        importer.import(anime)

        expect(client).not_to have_received(:watch_providers)
        expect(StreamingAvailability.count).to eq(0)
      end
    end
  end
  describe "#import of the logos and the watch pages" do
    it "stores the logo of the platform" do
      importer.import(anime)

      expect(StreamingPlatform.find_by!(slug: "crunchyroll").logo_path).to eq("/crunchyroll.jpg")
    end

    it "refreshes the logo that TMDB has changed" do
      create(:streaming_platform, name: "Crunchyroll", slug: "crunchyroll", tmdb_provider_id: 283, logo_path: "/old.jpg")

      importer.import(anime)

      expect(StreamingPlatform.find_by!(slug: "crunchyroll").logo_path).to eq("/crunchyroll.jpg")
    end

    it "does not take the logo of a variant of a platform" do
      variant = provider(1, "Netflix Standard with Ads").merge("logo_path" => "/variant.jpg")
      allow(client).to receive(:watch_providers).and_return("FR" => { "flatrate" => [ variant ] })

      importer.import(anime)

      expect(StreamingPlatform.find_by!(slug: "netflix").logo_path).to be_nil
    end

    it "stores the watch page of TMDB for each country" do
      importer.import(anime)

      expect(tmdb_match.reload.watch_links).to include("FR" => "https://www.themoviedb.org/tv/209867/watch?locale=FR")
    end

    it "ignores the watch page of a country that is not supported" do
      allow(client).to receive(:watch_providers)
        .and_return(providers.merge("JP" => { "link" => "https://www.themoviedb.org/tv/209867/watch?locale=JP" }))

      importer.import(anime)

      expect(tmdb_match.reload.watch_links).not_to have_key("JP")
    end

    it "replaces the watch pages of the previous import" do
      tmdb_match.update!(watch_links: { "BE" => "https://www.themoviedb.org/tv/209867/watch?locale=BE" })

      importer.import(anime)

      expect(tmdb_match.reload.watch_links).not_to have_key("BE")
    end
  end
end
