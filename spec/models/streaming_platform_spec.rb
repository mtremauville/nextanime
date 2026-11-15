require "rails_helper"

RSpec.describe StreamingPlatform, type: :model do
  subject(:platform) { build(:streaming_platform) }

  it "has a valid factory" do
    expect(platform).to be_valid
  end

  describe "associations" do
    it { is_expected.to have_many(:streaming_links).dependent(:destroy) }
    it { is_expected.to have_many(:streaming_availabilities).dependent(:destroy) }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:slug).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:name).unique(true) }
    it { is_expected.to have_db_index(:slug).unique(true) }
    it { is_expected.to have_db_column(:tmdb_provider_id).of_type(:integer) }
    it { is_expected.to have_db_index(:tmdb_provider_id).unique(true) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:tmdb_provider_id).allow_nil }
  end
  describe "#logo_url" do
    it "points to the logo on the image server of TMDB" do
      platform = build(:streaming_platform, logo_path: "/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg")

      expect(platform.logo_url).to eq("https://image.tmdb.org/t/p/w92/pbpMk2JmcoNnQwx5JGpXngfoWtp.jpg")
    end

    it "has no logo address when the platform has no logo" do
      expect(build(:streaming_platform, logo_path: nil).logo_url).to be_nil
    end
  end
  describe "#homepage_url" do
    it "gives the home page of a known platform" do
      expect(described_class.new(name: "Netflix").homepage_url).to eq("https://www.netflix.com")
    end

    it "gives nothing for a platform that is not listed" do
      expect(described_class.new(name: "Unknown platform").homepage_url).to be_nil
    end

    it "lists only secure web addresses" do
      expect(described_class::HOMEPAGES.values).to all(start_with("https://"))
    end
  end
  describe "#search_url" do
    it "searches the title on a platform whose search is known" do
      expect(described_class.new(name: "Netflix").search_url("Attack on Titan"))
        .to eq("https://www.netflix.com/search?q=Attack%20on%20Titan")
    end

    it "encodes what is not safe in an address" do
      expect(described_class.new(name: "Netflix").search_url("Fate/Zero & more"))
        .to eq("https://www.netflix.com/search?q=Fate%2FZero%20%26%20more")
    end

    it "gives nothing for a platform whose search is not known" do
      expect(described_class.new(name: "Unknown platform").search_url("Attack on Titan")).to be_nil
    end

    it "lists only secure addresses that take the title" do
      expect(described_class::SEARCH_URLS.values).to all(start_with("https://").and(include("%{query}")))
    end
  end
end
