module Molecules
  # The logos of the platforms that offer an anime, for its card: three at most, then how many are
  # left. It shows nothing without any platform, because an anime that is not known to be on a
  # platform is not known to be unavailable either.
  # The logos are decorative: the names of all the platforms are written for the screen readers.
  class PlatformBadgesComponent < ViewComponent::Base
    MAX_LOGOS = 3

    def initialize(platforms:, max: MAX_LOGOS)
      @platforms = platforms
      @max = max
      super()
    end

    def render? = @platforms.any?

    private

    def shown_platforms = @platforms.first(@max)

    def hidden_count = @platforms.size - shown_platforms.size

    def names = @platforms.map(&:name).join(", ")
  end
end
