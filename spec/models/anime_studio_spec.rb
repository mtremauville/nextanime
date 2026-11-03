require "rails_helper"

RSpec.describe AnimeStudio, type: :model do
  subject(:anime_studio) { build(:anime_studio) }

  it "has a valid factory" do
    expect(anime_studio).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:anime) }
    it { is_expected.to belong_to(:studio) }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:main).of_type(:boolean).with_options(null: false, default: false) }
    it { is_expected.to have_db_index(%i[anime_id studio_id]).unique(true) }
    it { is_expected.to have_db_index(:studio_id) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:studio_id).scoped_to(:anime_id) }

    context "when the anime already has a main studio" do
      let(:anime) { create(:anime) }

      before { create(:anime_studio, anime: anime, main: true) }

      it "rejects a second main studio" do
        expect(build(:anime_studio, anime: anime, main: true)).not_to be_valid
      end

      it "accepts a secondary studio" do
        expect(build(:anime_studio, anime: anime, main: false)).to be_valid
      end
    end
  end

  describe "database constraints" do
    it "also allows a single main studio per anime when validations are skipped" do
      anime = create(:anime)
      create(:anime_studio, anime: anime, main: true)
      duplicate = build(:anime_studio, anime: anime, main: true)

      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
