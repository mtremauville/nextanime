class ImportTopAnimeJob < ApplicationJob
  include AnilistResilient

  queue_as :default

  TOP_ANIME_LIMIT = 500
  PAUSE_BETWEEN_PAGES = 2.seconds

  def perform(page: 1, remaining: TOP_ANIME_LIMIT)
    anilist_page = Anilist::Client.new.top_anime(page: page)
    media = anilist_page.media.first(remaining)

    media.each { |item| import(item) }

    still_wanted = remaining - media.size
    return unless anilist_page.has_next_page && still_wanted.positive?

    self.class.set(wait: PAUSE_BETWEEN_PAGES).perform_later(page: page + 1, remaining: still_wanted)
  end

  private

  def import(media)
    Anilist::AnimeImporter.new.import(media)
  rescue ActiveRecord::RecordInvalid => error
    Rails.logger.warn("ImportTopAnimeJob skipped anime #{media['id']}: #{error.message}")
  end
end
