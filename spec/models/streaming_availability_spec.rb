require "rails_helper"

RSpec.describe StreamingAvailability, type: :model do
  subject(:availability) { build(:streaming_availability) }

  it "has a valid factory" do
    expect(availability).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:anime) }
    it { is_expected.to belong_to(:streaming_platform) }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:country_code).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:offer_type).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(%i[anime_id streaming_platform_id country_code offer_type]).unique(true) }
    it { is_expected.to have_db_index(%i[streaming_platform_id country_code]) }
  end

  describe "offer types" do
    it do
      expect(availability).to define_enum_for(:offer_type)
        .with_values(flatrate: "flatrate", free: "free", ads: "ads")
        .backed_by_column_of_type(:string)
        .with_prefix(:offer)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:country_code) }

    %w[FR US].each do |code|
      it { is_expected.to allow_value(code).for(:country_code) }
    end

    %w[fr FRA F].each do |code|
      it { is_expected.not_to allow_value(code).for(:country_code) }
    end

    context "when the same offer is already stored" do
      let(:stored) { create(:streaming_availability) }

      it "rejects it again" do
        duplicate = build(:streaming_availability, anime: stored.anime, streaming_platform: stored.streaming_platform)

        expect(duplicate).not_to be_valid
      end

      it "accepts the same offer in another country" do
        other = build(:streaming_availability, anime: stored.anime, streaming_platform: stored.streaming_platform, country_code: "BE")

        expect(other).to be_valid
      end

      it "accepts another type of offer" do
        other = build(:streaming_availability, anime: stored.anime, streaming_platform: stored.streaming_platform, offer_type: :free)

        expect(other).to be_valid
      end
    end
  end
end
