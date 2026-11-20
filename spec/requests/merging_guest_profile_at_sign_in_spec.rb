require "rails_helper"

RSpec.describe "Merging the guest profile at sign in", type: :request do
  let(:anime) { create(:anime) }
  let(:password) { "a-long-password-123" }
  let!(:account) { create(:user, password: password, password_confirmation: password) }

  def sign_in_through_the_form(password: self.password)
    post user_session_path, params: { user: { email: account.email, password: password } }
  end

  context "when the visitor swiped before signing in" do
    before { post swipes_path, params: { anime_id: anime.id, liked: true } }

    it "gives the swipes to an account that has no profile yet" do
      sign_in_through_the_form

      expect(account.reload.taste_profile.swiped_anime_ids).to eq([ anime.id ])
    end

    it "adds the swipes to the profile the account already has" do
      known_anime = create(:anime)
      create(:taste_profile, :with_user, user: account).record_swipe(known_anime, liked: false)

      sign_in_through_the_form

      expect(account.reload.taste_profile.swiped_anime_ids).to contain_exactly(known_anime.id, anime.id)
    end

    it "keeps the verdict of the account for an anime swiped on both sides" do
      new_anime = create(:anime)
      post swipes_path, params: { anime_id: new_anime.id, liked: true }
      create(:taste_profile, :with_user, user: account).record_swipe(anime, liked: false)

      sign_in_through_the_form

      swipes = account.reload.taste_profile.swipes
      expect(swipes.find_by(anime: anime)).not_to be_liked
      expect(swipes.find_by(anime: new_anime)).to be_liked
    end

    it "forgets the guest cookie once the swipes are merged" do
      sign_in_through_the_form

      expect(cookies[:taste_session]).to be_blank
    end

    it "removes the guest profile" do
      create(:taste_profile, :with_user, user: account)

      sign_in_through_the_form

      expect(TasteProfile.where.not(session_token: nil)).to be_none
    end

    it "keeps the guest profile and its cookie when the sign in is refused" do
      sign_in_through_the_form(password: "wrong-password-123")

      expect(account.reload.taste_profile).to be_nil
      expect(TasteProfile.where.not(session_token: nil).count).to eq(1)
      expect(cookies[:taste_session]).to be_present
    end
  end

  context "when the visitor never swiped" do
    it "signs in without creating any profile" do
      sign_in_through_the_form

      expect(account.reload.taste_profile).to be_nil
    end
  end

  context "with a cookie that points to somebody else's profile" do
    it "leaves that profile alone" do
      other = TasteProfile.for_session("someone-else")
      cookies[:taste_session] = "someone-else"

      sign_in_through_the_form

      expect(other.reload.user).to be_nil
      expect(account.reload.taste_profile).to be_nil
    end
  end
end
