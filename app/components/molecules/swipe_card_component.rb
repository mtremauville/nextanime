module Molecules
  class SwipeCardComponent < ViewComponent::Base
    delegate :badge, :meta, :genre_labels, to: :summary

    def initialize(anime:)
      @anime = anime
      @summary = AnimeSummary.new(anime)
      super()
    end

    private

    attr_reader :anime, :summary
  end
end
