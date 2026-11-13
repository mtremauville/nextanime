require "rails_helper"

RSpec.describe Tmdb::AvailabilitySync do
  subject(:sync) { described_class.new(importer: importer) }

  let(:importer) { instance_double(Tmdb::AvailabilityImporter) }
  let(:found) { instance_double(TmdbMatch, matched?: true) }
  let(:missing) { instance_double(TmdbMatch, matched?: false) }
  let(:matched_anime) { create(:anime) }
  let(:unmatched_anime) { create(:anime) }
  let(:failing_anime) { create(:anime) }

  describe "#call" do
    before do
      allow(importer).to receive(:import).with(matched_anime).and_return(found)
      allow(importer).to receive(:import).with(unmatched_anime).and_return(missing)
      allow(importer).to receive(:import).with(failing_anime).and_raise(Tmdb::ConnectionError, "Could not reach TMDB: timeout")
    end

    it "imports the availabilities of every anime" do
      sync.call([ matched_anime, unmatched_anime, failing_anime ])

      expect(importer).to have_received(:import).exactly(3).times
    end

    it "sorts the anime by the outcome of their import" do
      report = sync.call([ matched_anime, unmatched_anime, failing_anime ])

      expect(report.matched).to eq([ matched_anime ])
      expect(report.unmatched).to eq([ unmatched_anime ])
      expect(report.failed.map(&:anime)).to eq([ failing_anime ])
    end

    it "keeps the error of an anime that failed" do
      report = sync.call([ failing_anime ])

      expect(report.failed.first.error).to be_a(Tmdb::ConnectionError)
    end

    it "keeps going after a TMDB failure" do
      report = sync.call([ failing_anime, matched_anime ])

      expect(report.matched).to eq([ matched_anime ])
    end

    it "does not hide the other errors" do
      allow(importer).to receive(:import).with(matched_anime).and_raise(ArgumentError)

      expect { sync.call([ matched_anime ]) }.to raise_error(ArgumentError)
    end
  end

  describe "the default importer" do
    it "is built on a TMDB client when none is given" do
      expect(described_class.new).to be_a(described_class)
    end
  end

  describe Tmdb::AvailabilitySync::Report do
    let(:frieren) { build_stubbed(:anime, title_romaji: "Frieren", anilist_id: 7) }
    let(:other) { build_stubbed(:anime) }
    let(:failure) do
      Tmdb::AvailabilitySync::Failure.new(
        anime: build_stubbed(:anime, title_romaji: "Broken", anilist_id: 9),
        error: Tmdb::ConnectionError.new("Could not reach TMDB: timeout")
      )
    end
    let(:report) { described_class.new(matched: [ other, other ], unmatched: [ frieren ], failed: [ failure ]) }

    describe "#match_rate" do
      it "is the share of matched anime among the anime that were tried" do
        expect(report.match_rate).to eq(66.7)
      end

      it "is nil when no anime could be tried" do
        expect(described_class.new(matched: [], unmatched: [], failed: [ failure ]).match_rate).to be_nil
      end
    end

    describe "#to_s" do
      it "counts the anime by outcome" do
        expect(report.to_s).to include("4 anime processed: 2 matched, 1 not matched, 1 failed")
      end

      it "gives the match rate" do
        expect(report.to_s).to include("Match rate: 66.7 %")
      end

      it "lists the anime that were not matched" do
        expect(report.to_s).to include("Not matched:\n  - Frieren (AniList 7)")
      end

      it "lists the anime that failed with their error" do
        expect(report.to_s).to include("Failed:\n  - Broken: Could not reach TMDB: timeout")
      end

      it "leaves out the lists that are empty" do
        all_matched = described_class.new(matched: [ other ], unmatched: [], failed: [])

        expect(all_matched.to_s).not_to include("Not matched", "Failed")
      end

      it "has no match rate when nothing was processed" do
        empty = described_class.new(matched: [], unmatched: [], failed: [])

        expect(empty.to_s).to eq("0 anime processed: 0 matched, 0 not matched, 0 failed")
      end
    end
  end
end
