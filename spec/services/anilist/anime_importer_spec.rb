require "rails_helper"

RSpec.describe Anilist::AnimeImporter do
  include ActiveSupport::Testing::TimeHelpers

  subject(:importer) { described_class.new }

  let(:medias) { JSON.parse(file_fixture("anilist/top_anime_page.json").read).dig("data", "Page", "media") }
  let(:bebop) { medias.first }
  let(:frieren) { medias.second }

  describe "#import" do
    context "with a new anime" do
      subject(:anime) { importer.import(bebop) }

      it "creates the anime" do
        expect { anime }.to change(Anime, :count).by(1)
      end

      it "returns the saved anime with its AniList id" do
        expect(anime).to be_persisted
        expect(anime.anilist_id).to eq(1)
      end

      it "stores the three titles" do
        expect(anime).to have_attributes(
          title_romaji: "Cowboy Bebop", title_english: "Cowboy Bebop", title_native: "カウボーイビバップ"
        )
      end

      it "stores the description" do
        expect(anime.description).to eq("Bounty hunters travel the solar system.")
      end

      it "stores the cover and the banner" do
        expect(anime).to have_attributes(
          cover_image_url: "https://example.test/covers/1.jpg",
          banner_image_url: "https://example.test/banners/1.jpg"
        )
      end

      it "stores the format, the airing status and the season" do
        expect(anime).to be_format_tv
        expect(anime).to be_airing_finished
        expect(anime).to be_season_spring
      end

      it "stores the numbers" do
        expect(anime).to have_attributes(
          season_year: 1998, episodes: 26, duration: 24, average_score: 86, popularity: 300_000
        )
      end

      it "stores the start and end dates" do
        expect(anime).to have_attributes(start_date: Date.new(1998, 4, 3), end_date: Date.new(1999, 4, 24))
      end

      it "has no next episode when none is scheduled" do
        expect(anime).to have_attributes(next_episode: nil, next_airing_at: nil)
      end

      it "stamps the synchronization time" do
        now = Time.zone.local(2026, 10, 27, 12, 0)

        travel_to(now) { expect(anime.synced_at).to eq(now) }
      end
    end

    context "with an anime that is still airing" do
      subject(:anime) { importer.import(frieren) }

      it "stores the next episode and its airing time" do
        expect(anime).to have_attributes(next_episode: 29, next_airing_at: Time.zone.at(1_798_761_600))
      end

      it "has no end date while the end is unknown" do
        expect(anime.end_date).to be_nil
      end

      it "has no banner when AniList has none" do
        expect(anime.banner_image_url).to be_nil
      end
    end

    describe "fuzzy dates" do
      it "falls back to January when only the year is known" do
        anime = importer.import(bebop.merge("startDate" => { "year" => 1998, "month" => nil, "day" => nil }))

        expect(anime.start_date).to eq(Date.new(1998, 1, 1))
      end

      it "falls back to the first day when the day is unknown" do
        anime = importer.import(bebop.merge("startDate" => { "year" => 1998, "month" => 4, "day" => nil }))

        expect(anime.start_date).to eq(Date.new(1998, 4, 1))
      end

      it "has no date when AniList gives none" do
        anime = importer.import(bebop.merge("startDate" => nil))

        expect(anime.start_date).to be_nil
      end
    end

    describe "genres" do
      it "links the genres of the anime" do
        expect(importer.import(bebop).genres.map(&:name)).to contain_exactly("Action", "Sci-Fi")
      end

      it "reuses a genre that already exists" do
        create(:genre, name: "Action")

        expect { importer.import(bebop) }.to change(Genre, :count).by(1)
      end
    end

    describe "tags" do
      it "creates the tag with its category" do
        tag = importer.import(bebop).tags.first

        expect(tag).to have_attributes(anilist_tag_id: 101, name: "Space", category: "Setting-Universe", adult: false)
      end

      it "keeps the rank of the tag for this anime" do
        expect(importer.import(bebop).anime_tags.first.rank).to eq(90)
      end

      it "updates a tag that already exists instead of duplicating it" do
        create(:tag, anilist_tag_id: 101, name: "Old name")

        expect { importer.import(bebop) }.not_to change(Tag, :count)
        expect(Tag.find_by(anilist_tag_id: 101).name).to eq("Space")
      end

      it "flags adult tags" do
        adult_tag = { "id" => 303, "name" => "Nudity", "category" => "Sexual Content", "rank" => 60, "isAdult" => true }
        anime = importer.import(bebop.merge("tags" => [ adult_tag ]))

        expect(anime.tags.first).to be_adult
      end
    end

    describe "studios" do
      it "keeps the animation studios only" do
        expect(importer.import(bebop).studios.map(&:name)).to eq([ "Sunrise" ])
      end

      it "flags the main studio" do
        expect(importer.import(bebop).main_studio.name).to eq("Sunrise")
      end

      it "updates a studio that already exists instead of duplicating it" do
        create(:studio, anilist_studio_id: 14, name: "Old name")

        expect { importer.import(bebop) }.not_to change(Studio, :count)
        expect(Studio.find_by(anilist_studio_id: 14).name).to eq("Sunrise")
      end
    end

    describe "studios listed in a surprising way" do
      def edge(id, name, main:)
        { "isMain" => main, "node" => { "id" => id, "name" => name, "isAnimationStudio" => true } }
      end

      def import_with(edges)
        importer.import(bebop.merge("studios" => { "edges" => edges }))
      end

      it "links a studio listed twice only once" do
        anime = import_with([ edge(14, "Sunrise", main: false), edge(14, "Sunrise", main: false) ])

        expect(anime.anime_studios.count).to eq(1)
      end

      it "keeps the main flag when only one of the listings has it" do
        anime = import_with([ edge(14, "Sunrise", main: false), edge(14, "Sunrise", main: true) ])

        expect(anime.main_studio.name).to eq("Sunrise")
      end

      it "keeps a single main studio when AniList flags several" do
        anime = import_with([ edge(14, "Sunrise", main: true), edge(99, "Bones", main: true) ])

        expect(anime.studios.count).to eq(2)
        expect(anime.anime_studios.where(main: true).count).to eq(1)
        expect(anime.main_studio.name).to eq("Sunrise")
      end

      it "has no main studio when AniList flags none" do
        anime = import_with([ edge(14, "Sunrise", main: false) ])

        expect(anime.main_studio).to be_nil
      end
    end
    describe "importing the same anime again" do
      before { importer.import(bebop) }

      it "does not duplicate the anime nor its links" do
        expect { importer.import(bebop) }.not_to change {
          [ Anime.count, AnimeGenre.count, AnimeTag.count, AnimeStudio.count ]
        }
      end

      it "updates the attributes" do
        importer.import(bebop.merge("popularity" => 310_000, "title" => bebop["title"].merge("english" => "Bebop")))

        expect(Anime.find_by(anilist_id: 1)).to have_attributes(popularity: 310_000, title_english: "Bebop")
      end

      it "drops the genres that AniList removed" do
        anime = importer.import(bebop.merge("genres" => [ "Action" ]))

        expect(anime.genres.map(&:name)).to eq([ "Action" ])
      end

      it "follows a change of main studio" do
        edges = [
          { "isMain" => false, "node" => { "id" => 14, "name" => "Sunrise", "isAnimationStudio" => true } },
          { "isMain" => true, "node" => { "id" => 99, "name" => "Bones", "isAnimationStudio" => true } }
        ]
        anime = importer.import(bebop.merge("studios" => { "edges" => edges }))

        expect(anime.main_studio.name).to eq("Bones")
        expect(anime.studios.count).to eq(2)
      end
    end

    describe "invalid data" do
      it "saves nothing when a link is invalid" do
        broken_tag = { "id" => 101, "name" => "Space", "category" => nil, "rank" => 150, "isAdult" => false }

        expect { importer.import(bebop.merge("tags" => [ broken_tag ])) }.to raise_error(ActiveRecord::RecordInvalid)
        expect([ Anime.count, Genre.count, Tag.count ]).to eq([ 0, 0, 0 ])
      end

      it "refuses a format that AniList may have added later" do
        expect { importer.import(bebop.merge("format" => "HOLOGRAM")) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
