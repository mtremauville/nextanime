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
end
