module Tmdb
  class RateLimitedError < ResponseError
    MESSAGE = "TMDB rate limit reached".freeze
    STATUS = 429

    attr_reader :retry_after

    def initialize(retry_after: nil)
      super(MESSAGE, status: STATUS)
      @retry_after = retry_after
    end
  end
end
