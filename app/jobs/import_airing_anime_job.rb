# Imports the anime that are airing now: the ones the calendar needs.
class ImportAiringAnimeJob < ImportAnimePagesJob
  AIRING_ANIME_LIMIT = 500

  private

  def fetch_page(page) = Anilist::Client.new.airing_anime(page: page)

  def default_limit = AIRING_ANIME_LIMIT
end
