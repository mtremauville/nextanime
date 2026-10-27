require "net/http"
require "json"

module Anilist
  class Client
    ENDPOINT = URI("https://graphql.anilist.co").freeze
    DEFAULT_PER_PAGE = 50
    OPEN_TIMEOUT_SECONDS = 5
    READ_TIMEOUT_SECONDS = 15
    HEADERS = { "Content-Type" => "application/json", "Accept" => "application/json" }.freeze

    TOP_ANIME_QUERY = <<~GRAPHQL.freeze
      query ($page: Int!, $perPage: Int!) {
        Page(page: $page, perPage: $perPage) {
          pageInfo { currentPage hasNextPage }
          media(type: ANIME, sort: POPULARITY_DESC) {
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
            nextAiringEpisode { airingAt episode }
            genres
            tags { id name rank isAdult }
            studios { edges { isMain node { id name } } }
          }
        }
      }
    GRAPHQL

    def top_anime(page: 1, per_page: DEFAULT_PER_PAGE)
      data = execute(TOP_ANIME_QUERY, page: page, perPage: per_page)
      page_data = data.fetch("Page")
      page_info = page_data.fetch("pageInfo")

      Page.new(
        number: page_info.fetch("currentPage"),
        has_next_page: page_info.fetch("hasNextPage"),
        media: page_data.fetch("media")
      )
    end

    private

    def execute(query, variables)
      response = post({ query: query, variables: variables }.to_json)
      JSON.parse(response.body).fetch("data")
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
    end
  end
end
