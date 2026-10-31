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

  describe ".for_session" do
    it "creates the profile of a new session token" do
      profile = described_class.for_session("abc")

      expect(profile).to be_persisted
      expect(profile.session_token).to eq("abc")
    end

    it "finds the profile already linked to the token" do
      existing = create(:taste_profile, session_token: "abc")

      expect(described_class.for_session("abc")).to eq(existing)
    end
  end

  describe "#record_swipe" do
    let(:profile) { create(:taste_profile) }
    let(:anime) { create(:anime) }

    it "stores a like" do
      swipe = profile.record_swipe(anime, liked: true)

      expect(swipe).to be_persisted
      expect(swipe.liked).to be(true)
    end

    it "stores a pass" do
      swipe = profile.record_swipe(anime, liked: false)

      expect(swipe.liked).to be(false)
    end

    it "changes the verdict of an anime already swiped without duplicating it" do
      profile.record_swipe(anime, liked: false)

      expect { profile.record_swipe(anime, liked: true) }.not_to change(Swipe, :count)
      expect(profile.swipes.find_by(anime: anime).liked).to be(true)
    end
  end

  describe "#swiped_anime_ids" do
    let(:profile) { create(:taste_profile) }

    it "lists the anime the visitor liked or passed" do
      liked = create(:anime)
      passed = create(:anime)
      profile.record_swipe(liked, liked: true)
      profile.record_swipe(passed, liked: false)

      expect(profile.swiped_anime_ids).to contain_exactly(liked.id, passed.id)
    end

    it "is empty before the first swipe" do
      expect(profile.swiped_anime_ids).to eq([])
    end

    it "ignores the swipes of other profiles" do
      create(:swipe)

      expect(profile.swiped_anime_ids).to be_empty
    end
  end
end
