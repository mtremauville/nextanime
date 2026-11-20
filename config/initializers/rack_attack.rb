# Slows down what can be abused to guess passwords, flood a mailbox, create accounts in bulk
# or fill the database with guest profiles. The counters live in Rails.cache.
class Rack::Attack
  THROTTLED_MESSAGE = "Trop de tentatives. Réessaie dans quelques instants.".freeze

  def self.post_to?(request, path)
    request.post? && request.path == path
  end

  # Read defensively: the parameter comes from the outside and may not be a hash.
  def self.submitted_email(request)
    user = request.params["user"]
    user["email"].to_s.downcase.strip.presence if user.is_a?(Hash)
  end

  throttle("sign_in/ip", limit: 10, period: 1.minute) do |request|
    request.ip if post_to?(request, "/users/sign_in")
  end

  throttle("sign_up/ip", limit: 10, period: 1.hour) do |request|
    request.ip if post_to?(request, "/users")
  end

  throttle("password_reset/ip", limit: 5, period: 15.minutes) do |request|
    request.ip if post_to?(request, "/users/password")
  end

  throttle("password_reset/email", limit: 3, period: 1.hour) do |request|
    submitted_email(request) if post_to?(request, "/users/password")
  end

  throttle("swipes/ip", limit: 100, period: 1.minute) do |request|
    request.ip if post_to?(request, "/swipes")
  end

  self.throttled_responder = lambda do |request|
    period = request.env["rack.attack.match_data"][:period].to_i
    retry_after = period - (Time.now.to_i % period)

    [ 429, { "content-type" => "text/plain; charset=utf-8", "retry-after" => retry_after.to_s }, [ THROTTLED_MESSAGE ] ]
  end
end
