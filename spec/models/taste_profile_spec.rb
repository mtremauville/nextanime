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

  describe "#likes_count" do
    let(:taste_profile) { create(:taste_profile) }

    it "counts the likes only" do
      create_list(:swipe, 2, taste_profile: taste_profile, liked: true)
      create(:swipe, taste_profile: taste_profile, liked: false)

      expect(taste_profile.likes_count).to eq(2)
    end

    it "is zero before the first swipe" do
      expect(taste_profile.likes_count).to eq(0)
    end
  end

  describe "#top_genres" do
    let(:taste_profile) do
      build(:taste_profile, genre_weights: { "Drama" => 0.2, "Thriller" => 0.8, "Comedy" => 0.5, "Action" => -0.5, "Romance" => 0.0 })
    end

    it "lists the best genres first with their weight" do
      expect(taste_profile.top_genres).to eq([ [ "Thriller", 0.8 ], [ "Comedy", 0.5 ], [ "Drama", 0.2 ] ])
    end

    it "leaves out the genres that are avoided or neutral" do
      expect(taste_profile.top_genres.map(&:first)).not_to include("Action", "Romance")
    end

    it "keeps only the requested number of genres" do
      expect(taste_profile.top_genres(2).map(&:first)).to eq(%w[Thriller Comedy])
    end

    it "keeps the five best genres by default" do
      taste_profile.genre_weights = (1..7).to_h { |index| [ "Genre #{index}", index / 10.0 ] }

      expect(taste_profile.top_genres.map(&:first)).to eq([ "Genre 7", "Genre 6", "Genre 5", "Genre 4", "Genre 3" ])
    end

    it "is empty without any weight" do
      expect(build(:taste_profile).top_genres).to eq([])
    end
  end

  describe "#top_tags" do
    it "lists the best tags first and leaves out the avoided ones" do
      taste_profile = build(:taste_profile, tag_weights: { "Gore" => -0.4, "Mystery" => 0.3, "Time travel" => 0.6 })

      expect(taste_profile.top_tags).to eq([ [ "Time travel", 0.6 ], [ "Mystery", 0.3 ] ])
    end

    it "keeps the eight best tags by default" do
      taste_profile = build(:taste_profile, tag_weights: (1..10).to_h { |index| [ "Tag #{index}", index / 10.0 ] })

      expect(taste_profile.top_tags.size).to eq(8)
      expect(taste_profile.top_tags.first).to eq([ "Tag 10", 1.0 ])
    end
  end

  describe "#absorb" do
    subject(:account_profile) { create(:taste_profile, :with_user) }

    let(:guest_profile) { create(:taste_profile) }
    let(:shared_anime) { create(:anime) }

    it "takes the swipes of the guest that the account does not know yet" do
      new_anime = create(:anime)
      create(:swipe, taste_profile: guest_profile, anime: new_anime)

      account_profile.absorb(guest_profile)

      expect(account_profile.swiped_anime_ids).to eq([ new_anime.id ])
    end

    it "keeps the verdict of the account for an anime swiped on both sides" do
      create(:swipe, taste_profile: account_profile, anime: shared_anime, liked: true)
      create(:swipe, :passed, taste_profile: guest_profile, anime: shared_anime)

      account_profile.absorb(guest_profile)

      expect(account_profile.swipes.find_by(anime: shared_anime)).to be_liked
    end

    it "forgets the swipes of the guest that are in conflict" do
      create(:swipe, taste_profile: account_profile, anime: shared_anime)
      create(:swipe, :passed, taste_profile: guest_profile, anime: shared_anime)

      expect { account_profile.absorb(guest_profile) }.to change(Swipe, :count).from(2).to(1)
    end

    it "computes the weights again from the swipes of both profiles" do
      action = create(:genre, name: "Action")
      create(:swipe, taste_profile: account_profile, anime: create(:anime, genres: [ action ]))
      create(:swipe, taste_profile: guest_profile, anime: create(:anime, genres: [ action ]))

      account_profile.absorb(guest_profile)

      expect(account_profile.reload.genre_weights).to eq({ "Action" => 0.5 })
    end

    it "removes the guest profile" do
      account_profile.absorb(guest_profile)

      expect(described_class.exists?(guest_profile.id)).to be(false)
    end

    it "leaves the other profiles alone" do
      other_profile = create(:taste_profile)
      create(:swipe, taste_profile: other_profile)

      account_profile.absorb(guest_profile)

      expect(other_profile.reload.swipes.count).to eq(1)
    end
  end

  describe ".merge_session_profile" do
    let(:user) { create(:user) }
    let!(:guest_profile) { described_class.for_session("visitor-token") }

    context "when the account has no profile yet" do
      it "gives the guest profile to the account" do
        described_class.merge_session_profile("visitor-token", into: user)

        expect(user.reload.taste_profile).to eq(guest_profile)
      end
    end

    context "when the account already has a profile" do
      let!(:account_profile) { create(:taste_profile, :with_user, user: user) }

      it "returns the profile of the account" do
        expect(described_class.merge_session_profile("visitor-token", into: user)).to eq(account_profile)
      end

      it "brings the swipes of the guest into the profile of the account" do
        anime = create(:anime)
        guest_profile.record_swipe(anime, liked: true)

        described_class.merge_session_profile("visitor-token", into: user)

        expect(account_profile.reload.swiped_anime_ids).to eq([ anime.id ])
      end

      it "removes the guest profile" do
        described_class.merge_session_profile("visitor-token", into: user)

        expect(described_class.find_by(session_token: "visitor-token")).to be_nil
      end
    end

    it "does nothing without a token" do
      expect(described_class.merge_session_profile(nil, into: user)).to be_nil
      expect(user.reload.taste_profile).to be_nil
    end

    it "does nothing for an unknown token" do
      expect(described_class.merge_session_profile("other-token", into: user)).to be_nil
      expect(user.reload.taste_profile).to be_nil
    end

    it "leaves alone a profile that already belongs to another account" do
      owner = create(:user)
      guest_profile.update!(user: owner)

      expect(described_class.merge_session_profile("visitor-token", into: user)).to be_nil
      expect(guest_profile.reload.user).to eq(owner)
    end
  end
end
