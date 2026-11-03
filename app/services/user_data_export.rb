# Gathers what the app keeps about an account, in a form the user can take away.
# The encrypted password and the Devise tokens are never part of it.
class UserDataExport
  def initialize(user)
    @user = user
  end

  def call
    {
      exported_at: Time.current.iso8601,
      account: account,
      taste_profile: taste_profile,
      swipes: swipes,
      watchlist: watchlist
    }
  end

  private

  attr_reader :user

  def account
    {
      email: user.email,
      username: user.username,
      country: user.country,
      created_at: user.created_at.iso8601
    }
  end

  def taste_profile
    profile = user.taste_profile
    return unless profile

    {
      genre_weights: profile.genre_weights,
      tag_weights: profile.tag_weights,
      created_at: profile.created_at.iso8601
    }
  end

  def swipes
    profile = user.taste_profile
    return [] unless profile

    profile.swipes.includes(:anime).order(:created_at, :id).map do |swipe|
      { anime: anime_summary(swipe.anime), liked: swipe.liked, swiped_at: swipe.created_at.iso8601 }
    end
  end

  def watchlist
    user.watchlist_entries.includes(:anime).order(:created_at, :id).map do |entry|
      {
        anime: anime_summary(entry.anime),
        status: entry.status,
        progress: entry.progress,
        added_at: entry.created_at.iso8601
      }
    end
  end

  def anime_summary(anime)
    { anilist_id: anime.anilist_id, title: anime.display_title }
  end
end
