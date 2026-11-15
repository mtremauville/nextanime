module Anilist
  # The streaming platforms kept from the external links of AniList. Their names and slugs are the
  # ones the import of TMDB gives them, so both sources end up on the same platform.
  module StreamingSites
    PLATFORMS = [
      { name: "Crunchyroll", slug: "crunchyroll" },
      { name: "Netflix", slug: "netflix" },
      { name: "Disney Plus", slug: "disney-plus" },
      { name: "Amazon Prime Video", slug: "amazon-prime-video" },
      { name: "Apple TV+", slug: "apple-tv-plus" },
      { name: "HIDIVE", slug: "hidive" },
      { name: "Hulu", slug: "hulu" },
      { name: "HBO Max", slug: "hbo-max" },
      { name: "Adult Swim", slug: "adult-swim" },
      { name: "Tubi TV", slug: "tubi-tv" },
      { name: "YouTube", slug: "youtube" },
      { name: "Criterion Channel", slug: "criterion-channel" }
    ].freeze

    # The names are compared without the case ("HIDIVE" and "HiDive" are the same platform).
    PLATFORMS_BY_NAME = PLATFORMS.index_by { |platform| platform[:name].downcase }.freeze

    # AniList lists some platforms under another name.
    ALIASES = { "prime video" => "amazon prime video", "max" => "hbo max" }.freeze

    def self.platform_for(site)
      name = site&.downcase
      PLATFORMS_BY_NAME[ALIASES.fetch(name, name)]
    end
  end
end
