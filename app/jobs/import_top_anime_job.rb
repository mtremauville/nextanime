class ImportTopAnimeJob < ApplicationJob
  queue_as :default

  TOP_ANIME_LIMIT = 500
  PAUSE_BETWEEN_PAGES = 2.seconds
  DEFAULT_RATE_LIMIT_WAIT = 60.seconds
  MAX_RATE_LIMIT_RETRIES = 10

  retry_on Anilist::ConnectionError, wait: :polynomially_longer, attempts: 5

  rescue_from Anilist::RateLimitedError do |error|
    raise error if executions >= MAX_RATE_LIMIT_RETRIES

    retry_job(wait: error.retry_after&.seconds || DEFAULT_RATE_LIMIT_WAIT)
  end

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
