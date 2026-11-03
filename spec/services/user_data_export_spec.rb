require "rails_helper"

RSpec.describe UserDataExport do
  subject(:export) { described_class.new(user).call }

  let(:user) { create(:user, username: "mika", country: "FR") }

  def anime_summary(anime)
    { anilist_id: anime.anilist_id, title: anime.display_title }
  end

  it "says when the export was made" do
    expect(Time.zone.parse(export[:exported_at])).to be_within(1.minute).of(Time.current)
  end

  describe "account" do
    it "lists the e-mail address, the username, the country and the sign up date" do
      expect(export[:account]).to eq(
        email: user.email,
        username: "mika",
        country: "FR",
        created_at: user.created_at.iso8601
      )
    end

    it "never holds the password nor a token" do
      expect(export.to_json).not_to include(user.encrypted_password)
    end
  end

  describe "taste profile" do
    it "is empty when the user never swiped" do
      expect(export[:taste_profile]).to be_nil
    end

    it "holds the weights learned from the swipes" do
      profile = create(:taste_profile, :with_user, user: user,
                       genre_weights: { "Action" => 0.5 }, tag_weights: { "Mecha" => 0.2 })

      expect(export[:taste_profile]).to eq(
        genre_weights: { "Action" => 0.5 },
        tag_weights: { "Mecha" => 0.2 },
        created_at: profile.created_at.iso8601
      )
    end
  end

  describe "swipes" do
    it "is empty without any swipe" do
      expect(export[:swipes]).to eq([])
    end

    context "when the user swiped" do
      let(:profile) { create(:taste_profile, :with_user, user: user) }
      let(:liked_anime) { create(:anime) }
      let(:passed_anime) { create(:anime) }
      let!(:like) { create(:swipe, taste_profile: profile, anime: liked_anime) }
      let!(:pass) { create(:swipe, :passed, taste_profile: profile, anime: passed_anime) }

      it "lists every swipe with its anime and its verdict, oldest first" do
        expect(export[:swipes]).to eq([
          { anime: anime_summary(liked_anime), liked: true, swiped_at: like.created_at.iso8601 },
          { anime: anime_summary(passed_anime), liked: false, swiped_at: pass.created_at.iso8601 }
        ])
      end

      it "leaves out the swipes of other people" do
        create(:swipe, taste_profile: create(:taste_profile, :with_user, user: create(:user)))

        expect(export[:swipes].size).to eq(2)
      end
    end
  end

  describe "watchlist" do
    it "is empty without any entry" do
      expect(export[:watchlist]).to eq([])
    end

    context "when the user follows anime" do
      let(:anime) { create(:anime) }
      let!(:entry) { create(:watchlist_entry, user: user, anime: anime, status: :watching, progress: 3) }

      it "lists every entry with its anime, its status and its progress" do
        expect(export[:watchlist]).to eq([
          { anime: anime_summary(anime), status: "watching", progress: 3, added_at: entry.created_at.iso8601 }
        ])
      end

      it "leaves out the entries of other people" do
        create(:watchlist_entry, user: create(:user))

        expect(export[:watchlist].size).to eq(1)
      end
    end
  end
end
