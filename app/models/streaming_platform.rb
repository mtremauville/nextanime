class StreamingPlatform < ApplicationRecord
  # TMDB gives the path of a logo only: it is served by its image server, in the smallest size
  # that stays sharp for a logo shown at about 40 pixels.
  LOGO_BASE_URL = "https://image.tmdb.org/t/p/w92".freeze
  HOMEPAGES = YAML.safe_load_file(Rails.root.join("config/streaming_platform_homepages.yml")).freeze
  SEARCH_URLS = YAML.safe_load_file(Rails.root.join("config/streaming_platform_searches.yml")).freeze

  has_many :streaming_links, dependent: :destroy
  has_many :streaming_availabilities, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :tmdb_provider_id, uniqueness: true, allow_nil: true

  def logo_url
    "#{LOGO_BASE_URL}#{logo_path}" if logo_path.present?
  end

  def homepage_url = HOMEPAGES[name]

  # The search of a title on the platform, when the address of its search is known.
  def search_url(title)
    template = SEARCH_URLS[name]
    format(template, query: ERB::Util.url_encode(title)) if template
  end
end
