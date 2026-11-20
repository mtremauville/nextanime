# Shared by the jobs that call AniList: retry on network failures and wait
# for the delay AniList asks for when its rate limit is reached.
module AnilistResilient
  extend ActiveSupport::Concern

  DEFAULT_RATE_LIMIT_WAIT = 60.seconds
  MAX_RATE_LIMIT_RETRIES = 10

  included do
    retry_on Anilist::ConnectionError, wait: :polynomially_longer, attempts: 5

    rescue_from Anilist::RateLimitedError do |error|
      raise error if executions >= MAX_RATE_LIMIT_RETRIES

      retry_job(wait: error.retry_after&.seconds || DEFAULT_RATE_LIMIT_WAIT)
    end
  end
end
