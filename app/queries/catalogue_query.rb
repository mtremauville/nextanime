# The catalogue, the most popular anime first, cut into numbered pages.
# A page number that does not exist is brought back to the nearest one that does.
class CatalogueQuery
  PER_PAGE = 12
  FIRST_PAGE = 1
  CARD_ASSOCIATIONS = [ :genres, :main_studio, { anime_tags: :tag } ].freeze

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

  def initialize(page: FIRST_PAGE, per_page: PER_PAGE)
    @requested_page = page
    @per_page = per_page
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

  attr_reader :requested_page, :per_page

  def number
    @number ||= requested_number.clamp(FIRST_PAGE, total_pages)
  end

  def requested_number = Integer(requested_page.to_s, 10, exception: false) || FIRST_PAGE

  def total_count = @total_count ||= Anime.count

  def total_pages = [ total_count.fdiv(per_page).ceil, FIRST_PAGE ].max

  def animes_of(page_number)
    ranked_animes
      .preload(*CARD_ASSOCIATIONS)
      .offset((page_number - 1) * per_page)
      .limit(per_page)
      .to_a
  end

  # Without popularity an anime goes last: PostgreSQL would put it first in a descending order.
  def ranked_animes = Anime.order(Anime.arel_table[:popularity].desc.nulls_last, :id)
end
