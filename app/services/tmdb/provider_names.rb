module Tmdb
  # TMDB lists the variants of a platform as platforms of their own ("Netflix Standard with Ads",
  # "Crunchyroll Amazon Channel"): they are brought back to the platform they belong to.
  module ProviderNames
    VARIANT_SUFFIX = /\s+(?:(?:Standard|Basic)\s+)?with Ads\z|\s+(?:Amazon|Apple TV|Roku Premium|YouTube) Channel\z/i

    def self.base_name(name)
      name.sub(VARIANT_SUFFIX, "")
    end

    def self.slug(name)
      base_name(name).gsub("+", " Plus").parameterize
    end
  end
end
