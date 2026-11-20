module Anilist
  class GraphqlError < Error
    attr_reader :errors

    def initialize(errors)
      super("AniList returned GraphQL errors: #{errors.map { |error| error['message'] }.join(', ')}")
      @errors = errors
    end
  end
end
