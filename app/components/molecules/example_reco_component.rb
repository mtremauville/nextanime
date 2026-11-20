module Molecules
  # One recommendation of the example on the landing page. The anime is real, its match is made up.
  # Without a cover, the poster keeps its gradient.
  class ExampleRecoComponent < ViewComponent::Base
    def initialize(title:, meta:, match:, reason:, poster:, image_url: nil)
      raise ArgumentError, "Unknown poster: #{poster.inspect}" unless PosterCardComponent::POSTERS.include?(poster)

      super()
      @title = title
      @meta = meta
      @match = match
      @reason = reason
      @poster = poster
      @image_url = image_url
    end

    private

    attr_reader :title, :meta, :match, :reason, :image_url

    def poster_class
      "na-example-reco__poster na-poster--#{@poster}"
    end
  end
end
