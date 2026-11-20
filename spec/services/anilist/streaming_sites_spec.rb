require "rails_helper"

RSpec.describe Anilist::StreamingSites do
  describe ".platform_for" do
    it "returns the name and the slug of a known site" do
      expect(described_class.platform_for("Crunchyroll")).to eq(name: "Crunchyroll", slug: "crunchyroll")
    end

    it "handles the sites whose name has several words" do
      expect(described_class.platform_for("Disney Plus")).to eq(name: "Disney Plus", slug: "disney-plus")
    end

    it "gathers the aliases of a platform under one name" do
      expect(described_class.platform_for("Prime Video")).to eq(described_class.platform_for("Amazon Prime Video"))
    end

    it "returns nil for a site that is not a known platform" do
      expect(described_class.platform_for("Bilibili TV")).to be_nil
    end

    it "returns nil when there is no site" do
      expect(described_class.platform_for(nil)).to be_nil
    end
  end
  describe "the platforms shared with TMDB" do
    it "gathers Max and HBO Max under the name used by TMDB" do
      expect(described_class.platform_for("Max")).to eq(name: "HBO Max", slug: "hbo-max")
      expect(described_class.platform_for("HBO Max")).to eq(name: "HBO Max", slug: "hbo-max")
    end

    it "keeps the Criterion Channel" do
      expect(described_class.platform_for("Criterion Channel")).to eq(name: "Criterion Channel", slug: "criterion-channel")
    end

    it "ignores the case of the name of the site" do
      expect(described_class.platform_for("HiDive")).to eq(name: "HIDIVE", slug: "hidive")
      expect(described_class.platform_for("hidive")).to eq(described_class.platform_for("HIDIVE"))
    end

    it "gives every platform the slug that the import of TMDB would give it" do
      described_class::PLATFORMS.each do |platform|
        expect(Tmdb::ProviderNames.slug(platform[:name])).to eq(platform[:slug])
      end
    end
  end
end
