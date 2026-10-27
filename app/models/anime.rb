class Anime < ApplicationRecord
  enum :format, {
    tv: "TV",
    tv_short: "TV_SHORT",
    movie: "MOVIE",
    special: "SPECIAL",
    ova: "OVA",
    ona: "ONA",
    music: "MUSIC"
  }, prefix: true, validate: { allow_nil: true }

  enum :airing_status, {
    finished: "FINISHED",
    releasing: "RELEASING",
    not_yet_released: "NOT_YET_RELEASED",
    cancelled: "CANCELLED",
    hiatus: "HIATUS"
  }, prefix: :airing, validate: { allow_nil: true }

  enum :season, {
    winter: "WINTER",
    spring: "SPRING",
    summer: "SUMMER",
    fall: "FALL"
  }, prefix: true, validate: { allow_nil: true }

  has_many :anime_genres, dependent: :destroy
  has_many :genres, through: :anime_genres
  has_many :anime_tags, dependent: :destroy
  has_many :tags, through: :anime_tags
  has_many :anime_studios, dependent: :destroy
  has_many :studios, through: :anime_studios
  has_one :main_anime_studio, -> { where(main: true) }, class_name: "AnimeStudio"
  has_one :main_studio, through: :main_anime_studio, source: :studio
  has_many :swipes, dependent: :destroy
  has_many :recommendations, dependent: :destroy

  validates :anilist_id, presence: true, uniqueness: true
  validates :title_romaji, presence: true
  validates :average_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :episodes, :duration, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def display_title
    title_english.presence || title_romaji
  end
end
