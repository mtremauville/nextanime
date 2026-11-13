require "net/http"
require "json"

module Tmdb
  class Client
    BASE_URL = "https://api.themoviedb.org/3".freeze
    MEDIA_TYPES = %w[tv movie].freeze
    OPEN_TIMEOUT_SECONDS = 5
    READ_TIMEOUT_SECONDS = 15
    NETWORK_ERRORS = [
      Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError
    ].freeze

    def initialize(token: Rails.application.credentials.dig(:tmdb, :read_access_token))
      @token = token
    end

    # The titles matching a query, most relevant first.
    def search(media_type:, query:)
      results("search/#{media_segment(media_type)}", query: query, include_adult: false)
    end

    # The offers of a title, by country code (FR, US...).
    def watch_providers(media_type:, tmdb_id:)
      results("#{media_segment(media_type)}/#{Integer(tmdb_id)}/watch/providers")
    end

    private

    def results(path, params = {})
      get(path, params).fetch("results")
    rescue KeyError => error
      raise ResponseError, "TMDB sent an unexpected response: #{error.message}"
    end

    def media_segment(media_type)
      segment = media_type.to_s
      raise ArgumentError, "Unknown media type: #{media_type.inspect}" unless MEDIA_TYPES.include?(segment)

      segment
    end

    def get(path, params)
      response = perform(uri_for(path, params))
      ensure_success!(response)
      parse(response)
    end

    def uri_for(path, params)
      URI("#{BASE_URL}/#{path}").tap { |uri| uri.query = URI.encode_www_form(params) unless params.empty? }
    end

    def perform(uri)
      request = Net::HTTP::Get.new(uri, headers)

      Net::HTTP.start(
        uri.host, uri.port,
        use_ssl: true,
        open_timeout: OPEN_TIMEOUT_SECONDS,
        read_timeout: READ_TIMEOUT_SECONDS
      ) { |http| http.request(request) }
    rescue *NETWORK_ERRORS => error
      raise ConnectionError, "Could not reach TMDB: #{error.message}"
    end

    def headers
      { "Authorization" => "Bearer #{@token}", "Accept" => "application/json" }
    end

    def ensure_success!(response)
      return if response.is_a?(Net::HTTPSuccess)

      if response.code.to_i == RateLimitedError::STATUS
        raise RateLimitedError.new(retry_after: Integer(response["Retry-After"], exception: false))
      end

      raise ResponseError.new("TMDB answered HTTP #{response.code}", status: response.code.to_i)
    end

    def parse(response)
      JSON.parse(response.body)
    rescue JSON::ParserError
      raise ResponseError.new("TMDB sent an unreadable response", status: response.code.to_i)
    end
  end
end
