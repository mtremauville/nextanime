# Imports pages of anime from AniList one after the other, until the wanted
# number of anime is reached or AniList has no more pages.
#
# Subclasses say which pages to read (#fetch_page) and how many anime to import
# by default (#default_limit).
class ImportAnimePagesJob < ApplicationJob
  include AnilistResilient

  queue_as :default

  PAUSE_BETWEEN_PAGES = 2.seconds

  def perform(page: 1, remaining: default_limit)
    anilist_page = fetch_page(page)
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
    Rails.logger.warn("#{self.class.name} skipped anime #{media['id']}: #{error.message}")
  end
end
