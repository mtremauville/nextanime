# Imports the most popular anime of AniList.
class ImportTopAnimeJob < ImportAnimePagesJob
  TOP_ANIME_LIMIT = 500

  private

  def fetch_page(page) = Anilist::Client.new.top_anime(page: page)

  def default_limit = TOP_ANIME_LIMIT
end
