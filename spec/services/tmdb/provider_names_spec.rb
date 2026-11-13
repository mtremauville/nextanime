require "rails_helper"

RSpec.describe Tmdb::ProviderNames do
  describe ".base_name" do
    {
      "Netflix Standard with Ads" => "Netflix",
      "Netflix basic with Ads" => "Netflix",
      "Amazon Prime Video with Ads" => "Amazon Prime Video",
      "Crunchyroll Amazon Channel" => "Crunchyroll",
      "Crunchyroll Apple TV Channel" => "Crunchyroll",
      "Amazon Prime Video Free" => "Amazon Prime Video",
      "Fandango at Home Free" => "Fandango at Home",
      "Anime Digital Network" => "Animation Digital Network"
    }.each do |variant, base_name|
      it "reduces #{variant.inspect} to #{base_name.inspect}" do
        expect(described_class.base_name(variant)).to eq(base_name)
      end
    end

    [ "Netflix", "Disney Plus", "Apple TV Plus", "Apple TV", "ADN" ].each do |name|
      it "keeps #{name.inspect} as it is" do
        expect(described_class.base_name(name)).to eq(name)
      end
    end
  end

  describe ".slug" do
    {
      "Crunchyroll" => "crunchyroll",
      "Amazon Prime Video" => "amazon-prime-video",
      "Netflix Standard with Ads" => "netflix",
      "Apple TV+" => "apple-tv-plus",
      "Apple TV Plus" => "apple-tv-plus",
      "Disney+" => "disney-plus",
      "Amazon Prime Video Free" => "amazon-prime-video",
      "Amazon Prime Video Free with Ads" => "amazon-prime-video",
      "Anime Digital Network" => "animation-digital-network"
    }.each do |name, slug|
      it "gives #{slug.inspect} for #{name.inspect}" do
        expect(described_class.slug(name)).to eq(slug)
      end
    end
  end
end
