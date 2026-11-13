module Tmdb
  # TMDB lists the variants of a platform as platforms of their own ("Netflix Standard with Ads",
  # "Crunchyroll Amazon Channel", "Amazon Prime Video Free with Ads"): they are brought back to the
  # platform they belong to. A few platforms are also listed twice under different names.
  module ProviderNames
    VARIANT_SUFFIX = /
      (?:
        \s+(?:(?:Standard|Basic)\s+)?with\sAds |
        \s+(?:Amazon|Apple\sTV|Roku\sPremium|YouTube)\sChannel |
        \s+Free
      )+\z
    /xi
    ALIASES = { "Anime Digital Network" => "Animation Digital Network" }.freeze

    def self.base_name(name)
      base = name.sub(VARIANT_SUFFIX, "")
      ALIASES.fetch(base, base)
    end

    def self.slug(name)
      base_name(name).gsub("+", " Plus").parameterize
    end
  end
end
