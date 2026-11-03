require "net/http"
require "json"

module Anilist
  class Client
    ENDPOINT = URI("https://graphql.anilist.co").freeze
    DEFAULT_PER_PAGE = 50
    MAX_IDS_PER_REQUEST = DEFAULT_PER_PAGE
    OPEN_TIMEOUT_SECONDS = 5
    READ_TIMEOUT_SECONDS = 15
    HEADERS = { "Content-Type" => "application/json", "Accept" => "application/json" }.freeze
    NETWORK_ERRORS = [
      Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError
    ].freeze

    MEDIA_FIELDS = <<~GRAPHQL.freeze
      id
      title { romaji english native }
      format
      status
      season
      seasonYear
      episodes
      duration
      averageScore
      popularity
      description(asHtml: false)
      coverImage { large }
      bannerImage
      startDate { year month day }
      endDate { year month day }
      nextAiringEpisode { airingAt episode }
      genres
      tags { id name category rank isAdult }
      studios { edges { isMain node { id name isAnimationStudio } } }
    GRAPHQL

    TOP_ANIME_QUERY = <<~GRAPHQL.freeze
      query ($page: Int!, $perPage: Int!) {
        Page(page: $page, perPage: $perPage) {
          pageInfo { currentPage hasNextPage }
          media(type: ANIME, sort: POPULARITY_DESC) {
            #{MEDIA_FIELDS}
          }
        }
      }
    GRAPHQL

    MEDIA_BY_IDS_QUERY = <<~GRAPHQL.freeze
      query ($ids: [Int], $perPage: Int!) {
        Page(page: 1, perPage: $perPage) {
          media(type: ANIME, id_in: $ids) {
            #{MEDIA_FIELDS}
          }
        }
      }
    GRAPHQL

    def top_anime(page: 1, per_page: DEFAULT_PER_PAGE)
      page_from(TOP_ANIME_QUERY, page: page, perPage: per_page) do |page_data|
        page_info = page_data.fetch("pageInfo")

        Page.new(
          number: page_info.fetch("currentPage"),
          has_next_page: page_info.fetch("hasNextPage"),
          media: page_data.fetch("media")
        )
      end
    end

    def media_by_ids(ids)
      return [] if ids.empty?

      if ids.size > MAX_IDS_PER_REQUEST
        raise ArgumentError, "AniList accepts at most #{MAX_IDS_PER_REQUEST} ids per request"
      end

      page_from(MEDIA_BY_IDS_QUERY, ids: ids, perPage: ids.size) { |page_data| page_data.fetch("media") }
    end

    private

    def page_from(query, variables)
      yield execute(query, variables).fetch("Page")
    rescue KeyError => error
      raise ResponseError, "AniList sent an unexpected response: #{error.message}"
    end

    def execute(query, variables)
      response = post({ query: query, variables: variables }.to_json)
      ensure_success!(response)
      payload = parse(response)
      raise GraphqlError, payload["errors"] if payload["errors"]

      payload.fetch("data")
    end

    def post(body)
      request = Net::HTTP::Post.new(ENDPOINT, HEADERS)
      request.body = body

      Net::HTTP.start(
        ENDPOINT.host, ENDPOINT.port,
        use_ssl: true,
        open_timeout: OPEN_TIMEOUT_SECONDS,
        read_timeout: READ_TIMEOUT_SECONDS
      ) { |http| http.request(request) }
    rescue *NETWORK_ERRORS => error
      raise ConnectionError, "Could not reach AniList: #{error.message}"
    end

    def ensure_success!(response)
      return if response.is_a?(Net::HTTPSuccess)

      if response.code.to_i == RateLimitedError::STATUS
        raise RateLimitedError.new(retry_after: Integer(response["Retry-After"], exception: false))
      end

      raise ResponseError.new("AniList answered HTTP #{response.code}", status: response.code.to_i)
    end

    def parse(response)
      JSON.parse(response.body)
    rescue JSON::ParserError
      raise ResponseError.new("AniList sent an unreadable response", status: response.code.to_i)
    end
  end
end
