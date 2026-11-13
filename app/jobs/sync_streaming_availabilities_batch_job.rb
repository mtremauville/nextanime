# Synchronizes the streaming availabilities of a batch of anime. AvailabilitySync reports the failures
# instead of raising them, so the anime TMDB could not answer are played again from the report.
class SyncStreamingAvailabilitiesBatchJob < ApplicationJob
  queue_as :default

  MAX_ATTEMPTS = 5
  DEFAULT_RETRY_WAIT = 60.seconds
  TRANSIENT_ERRORS = [ Tmdb::ConnectionError, Tmdb::RateLimitedError ].freeze

  def perform(anime_ids, attempt = 1)
    report = Tmdb::AvailabilitySync.new.call(Anime.where(id: anime_ids))
    Rails.logger.info("#{self.class.name}: #{report}")

    transient, definitive = report.failed.partition { |failure| transient?(failure) }
    definitive.each { |failure| log_skipped(failure) }
    retry_later(transient, attempt)
  end

  private

  def transient?(failure)
    TRANSIENT_ERRORS.any? { |error_class| failure.error.is_a?(error_class) }
  end

  def retry_later(failures, attempt)
    return if failures.empty?

    if attempt >= MAX_ATTEMPTS
      failures.each { |failure| log_gave_up(failure) }
    else
      self.class.set(wait: wait_for(failures)).perform_later(failures.map { |failure| failure.anime.id }, attempt + 1)
    end
  end

  def wait_for(failures)
    delays = failures.filter_map { |failure| failure.error.try(:retry_after) }
    delays.empty? ? DEFAULT_RETRY_WAIT : delays.max.seconds
  end

  def log_skipped(failure)
    Rails.logger.warn("#{self.class.name} skipped anime #{failure.anime.id}: #{failure.error.message}")
  end

  def log_gave_up(failure)
    Rails.logger.warn(
      "#{self.class.name} gave up on anime #{failure.anime.id} after #{MAX_ATTEMPTS} attempts: #{failure.error.message}"
    )
  end
end
