module Molecules
  class PosterCardComponent < ViewComponent::Base
    POSTERS = %i[violet magenta cyan green orange indigo].freeze

    def initialize(title:, href:, meta: nil, tags: [], match: nil, poster: :violet, image_url: nil)
      raise ArgumentError, "Unknown poster: #{poster.inspect}" unless POSTERS.include?(poster)

      @title = title
      @href = href
      @meta = meta
      @tags = tags
      @match = match
      @poster = poster
      @image_url = image_url
      super()
    end

    private

    attr_reader :title, :href, :meta, :tags, :match, :image_url

    def poster_class
      "na-poster-card__poster na-poster--#{@poster}"
    end
  end
end
