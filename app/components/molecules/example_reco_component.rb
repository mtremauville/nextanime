module Molecules
  # One recommendation of the example on the landing page. The anime is real, its match is made up.
  class ExampleRecoComponent < ViewComponent::Base
    def initialize(title:, meta:, match:, reason:, poster:)
      raise ArgumentError, "Unknown poster: #{poster.inspect}" unless PosterCardComponent::POSTERS.include?(poster)

      super()
      @title = title
      @meta = meta
      @match = match
      @reason = reason
      @poster = poster
    end

    private

    attr_reader :title, :meta, :match, :reason

    def poster_class
      "na-example-reco__poster na-poster--#{@poster}"
    end
  end
end
