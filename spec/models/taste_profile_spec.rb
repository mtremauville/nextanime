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

  describe ".attach_session_profile" do
    let(:user) { create(:user) }
    let!(:profile) { described_class.for_session("visitor-token") }

    it "gives the profile of the session to the user" do
      described_class.attach_session_profile("visitor-token", to: user)

      expect(user.reload.taste_profile).to eq(profile)
    end

    it "returns the attached profile" do
      expect(described_class.attach_session_profile("visitor-token", to: user)).to eq(profile)
    end

    it "forgets the session token so that the cookie no longer opens the profile" do
      described_class.attach_session_profile("visitor-token", to: user)

      expect(profile.reload.session_token).to be_nil
    end

    it "keeps the swipes of the visitor" do
      anime = create(:anime)
      profile.record_swipe(anime, liked: true)

      described_class.attach_session_profile("visitor-token", to: user)

      expect(user.reload.taste_profile.swiped_anime_ids).to eq([ anime.id ])
    end

    it "does nothing without a token" do
      expect(described_class.attach_session_profile(nil, to: user)).to be_nil
      expect(user.reload.taste_profile).to be_nil
    end

    it "does nothing for an unknown token" do
      expect(described_class.attach_session_profile("other-token", to: user)).to be_nil
      expect(user.reload.taste_profile).to be_nil
    end

    it "does not take a profile that already belongs to an account" do
      owner = create(:user)
      profile.update!(user: owner)

      expect(described_class.attach_session_profile("visitor-token", to: user)).to be_nil
      expect(profile.reload.user).to eq(owner)
    end

    it "keeps the profile the user already has" do
      own_profile = described_class.create!(user: user)

      expect(described_class.attach_session_profile("visitor-token", to: user)).to be_nil
      expect(user.reload.taste_profile).to eq(own_profile)
      expect(profile.reload.session_token).to eq("visitor-token")
    end
  end

  describe "#reset!" do
    subject(:profile) do
      create(:taste_profile, genre_weights: { "Action" => 0.8 }, tag_weights: { "Isekai" => 0.4 })
    end

    it "removes the swipes" do
      create_list(:swipe, 2, taste_profile: profile)

      expect { profile.reset! }.to change { profile.swipes.count }.from(2).to(0)
    end

    it "removes the recommendations" do
      create(:recommendation, taste_profile: profile)

      expect { profile.reset! }.to change { profile.recommendations.count }.from(1).to(0)
    end

    it "forgets the weights learned from the swipes" do
      profile.reset!

      expect(profile.reload.genre_weights).to eq({})
      expect(profile.reload.tag_weights).to eq({})
    end

    it "keeps the profile and its owner" do
      expect { profile.reset! }.not_to change { profile.reload.session_token }
      expect(described_class.exists?(profile.id)).to be(true)
    end

    it "keeps the watchlist of the account" do
      account_profile = create(:taste_profile, :with_user)
      entry = create(:watchlist_entry, user: account_profile.user)

      account_profile.reset!

      expect(WatchlistEntry.exists?(entry.id)).to be(true)
    end

    it "leaves the swipes of other profiles alone" do
      other_swipe = create(:swipe)

      profile.reset!

      expect(Swipe.exists?(other_swipe.id)).to be(true)
    end
  end

  describe "#refresh_weights!" do
    subject(:profile) { create(:taste_profile) }

    it "stores the weights computed from the swipes" do
      anime = create(:anime)
      create(:anime_genre, anime: anime, genre: create(:genre, name: "Action"))
      create(:anime_tag, anime: anime, tag: create(:tag, name: "Démons"), rank: 80)
      create(:swipe, taste_profile: profile, anime: anime, liked: true)

      profile.refresh_weights!

      expect(profile.reload.genre_weights).to eq("Action" => 0.3333)
      expect(profile.tag_weights).to eq("Démons" => 0.2857)
    end

    it "forgets the weights of swipes that no longer exist" do
      profile.update!(genre_weights: { "Action" => 0.5 }, tag_weights: { "Démons" => 0.5 })

      profile.refresh_weights!

      expect(profile.reload.genre_weights).to eq({})
      expect(profile.tag_weights).to eq({})
    end
  end

  describe "taste weights" do
    subject(:profile) { create(:taste_profile) }

    let(:anime) do
      create(:anime).tap { |action| create(:anime_genre, anime: action, genre: create(:genre, name: "Action")) }
    end

    it "follow a like" do
      profile.record_swipe(anime, liked: true)

      expect(profile.reload.genre_weights).to eq("Action" => 0.3333)
    end

    it "follow a change of mind instead of adding up" do
      profile.record_swipe(anime, liked: true)
      profile.record_swipe(anime, liked: false)

      expect(profile.reload.genre_weights).to eq("Action" => -0.3333)
    end
  end
end
