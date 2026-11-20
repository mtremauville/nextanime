module Molecules
  class PlatformLineComponent < ViewComponent::Base
    def initialize(platforms:)
      @platforms = platforms
    end

    def render? = @platforms.any?

    private

    def best_platform = @platforms.first

    def other_platforms = @platforms.drop(1)

    def other_platforms? = other_platforms.any?

    def other_platform_names = other_platforms.map(&:name).join(", ")
  end
end
