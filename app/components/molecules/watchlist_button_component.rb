module Molecules
  # What the page of an anime offers about the watchlist: to add it for a member, to say it is
  # already there, or to invite a visitor to create an account first.
  class WatchlistButtonComponent < ViewComponent::Base
    def initialize(anime:, member:, entry:)
      @anime = anime
      @member = member
      @entry = entry
      super()
    end

    private

    attr_reader :anime, :member, :entry
  end
end
