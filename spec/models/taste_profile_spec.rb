require "rails_helper"

RSpec.describe TasteProfile, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many(:swipes).dependent(:destroy) }
    it { is_expected.to have_many(:recommendations).dependent(:destroy) }
  end

  describe "defaults" do
    subject(:profile) { described_class.new }

    it "starts with empty genre weights" do
      expect(profile.genre_weights).to eq({})
    end

    it "starts with empty tag weights" do
      expect(profile.tag_weights).to eq({})
    end
  end

  describe "owner" do
    it "is valid with a session token only" do
      expect(build(:taste_profile)).to be_valid
    end

    it "is valid with a user only" do
      expect(build(:taste_profile, :with_user)).to be_valid
    end

    it "is invalid without a user nor a session token" do
      profile = build(:taste_profile, session_token: nil, user: nil)

      expect(profile).not_to be_valid
      expect(profile.errors[:base]).to be_present
    end
  end

  describe "uniqueness" do
    it "rejects a second profile for the same user" do
      user = create(:user)
      create(:taste_profile, :with_user, user: user)
      duplicate = build(:taste_profile, :with_user, user: user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it "rejects a duplicated session token" do
      create(:taste_profile, session_token: "abc")
      duplicate = build(:taste_profile, session_token: "abc")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:session_token]).to be_present
    end

    it "accepts several profiles without a session token when they have a user" do
      create(:taste_profile, :with_user)

      expect(build(:taste_profile, :with_user)).to be_valid
    end
  end
end
