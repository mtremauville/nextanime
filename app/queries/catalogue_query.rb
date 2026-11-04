# The catalogue, the most popular anime first, cut into numbered pages.
# It can be narrowed to the anime whose title or studio holds a text.
# A page number that does not exist is brought back to the nearest one that does.
class CatalogueQuery
  PER_PAGE = 12
  FIRST_PAGE = 1
  CARD_ASSOCIATIONS = [ :genres, :main_studio, { anime_tags: :tag } ].freeze

  # Any studio of the anime counts, not only the main one. EXISTS keeps an anime
  # that matches through several studios from being listed several times.
  MATCHING_SEARCH = <<~SQL.squish.freeze
    animes.title_romaji ILIKE :pattern OR animes.title_english ILIKE :pattern OR animes.title_native ILIKE :pattern
    OR EXISTS (
      SELECT 1 FROM anime_studios
      INNER JOIN studios ON studios.id = anime_studios.studio_id
      WHERE anime_studios.anime_id = animes.id AND studios.name ILIKE :pattern
    )
  SQL

  # One page of the catalogue, with what a pagination needs to know about it.
  Page = Data.define(:animes, :number, :total_count, :per_page, :total_pages) do
    def previous_number
      number - 1 if number > FIRST_PAGE
    end

    def next_number
      number + 1 if number < total_pages
    end

    def shown_count = (number - 1) * per_page + animes.size
  end

  def initialize(page: FIRST_PAGE, per_page: PER_PAGE, search: nil)
    @requested_page = page
    @per_page = per_page
    @search = search.to_s.strip
  end

  def call
    Page.new(
      animes: animes_of(number),
      number: number,
      total_count: total_count,
      per_page: per_page,
      total_pages: total_pages
    )
  end

  private

  attr_reader :requested_page, :per_page, :search

  def number
    @number ||= requested_number.clamp(FIRST_PAGE, total_pages)
  end

  def requested_number = Integer(requested_page.to_s, 10, exception: false) || FIRST_PAGE

  def total_count = @total_count ||= matching_animes.count

  def total_pages = [ total_count.fdiv(per_page).ceil, FIRST_PAGE ].max

  def animes_of(page_number)
    ranked_animes
      .preload(*CARD_ASSOCIATIONS)
      .offset((page_number - 1) * per_page)
      .limit(per_page)
      .to_a
  end

  # Without popularity an anime goes last: PostgreSQL would put it first in a descending order.
  def ranked_animes = matching_animes.order(Anime.arel_table[:popularity].desc.nulls_last, :id)

  def matching_animes
    return Anime.all if search.empty?

    Anime.where(MATCHING_SEARCH, pattern: "%#{Anime.sanitize_sql_like(search)}%")
  end
end
