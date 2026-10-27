require "rails_helper"

RSpec.describe Recommendation, type: :model do
  it "has a valid factory" do
    expect(build(:recommendation)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:taste_profile).required }
    it { is_expected.to belong_to(:anime).required }
  end

  describe "columns" do
    it { is_expected.to have_db_column(:score).of_type(:decimal).with_options(null: false) }
    it { is_expected.to have_db_column(:explanation).of_type(:text) }
    it { is_expected.to have_db_column(:explanation_digest).of_type(:string) }
    it { is_expected.to have_db_column(:explained_at).of_type(:datetime) }
    it { is_expected.to have_db_index([ :taste_profile_id, :anime_id ]).unique }
    it { is_expected.to have_db_index([ :taste_profile_id, :score ]) }
    it { is_expected.to have_db_index(:anime_id) }
  end

  describe "validations" do
    subject { create(:recommendation) }

    it { is_expected.to validate_uniqueness_of(:anime_id).scoped_to(:taste_profile_id) }
    it { is_expected.to validate_presence_of(:score) }
    it { is_expected.to validate_numericality_of(:score).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1) }
  end

  describe "explanation" do
    it "is optional until the text is generated" do
      recommendation = build(:recommendation, explanation: nil, explanation_digest: nil, explained_at: nil)

      expect(recommendation).to be_valid
    end
  end
end
