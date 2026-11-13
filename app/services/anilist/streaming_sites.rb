module Anilist
  # The streaming platforms kept from the external links of AniList.
  module StreamingSites
    PLATFORMS = [
      { name: "Crunchyroll", slug: "crunchyroll" },
      { name: "Netflix", slug: "netflix" },
      { name: "Disney Plus", slug: "disney-plus" },
      { name: "Amazon Prime Video", slug: "amazon-prime-video" },
      { name: "Apple TV+", slug: "apple-tv-plus" },
      { name: "HIDIVE", slug: "hidive" },
      { name: "Hulu", slug: "hulu" },
      { name: "Max", slug: "max" },
      { name: "Adult Swim", slug: "adult-swim" },
      { name: "Tubi TV", slug: "tubi-tv" },
      { name: "YouTube", slug: "youtube" }
    ].freeze

    PLATFORMS_BY_NAME = PLATFORMS.index_by { |platform| platform[:name] }.freeze

    # AniList lists some platforms under two names.
    ALIASES = { "Prime Video" => "Amazon Prime Video" }.freeze

    def self.platform_for(site)
      PLATFORMS_BY_NAME[ALIASES.fetch(site, site)]
    end
  end
end
