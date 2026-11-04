# The catalogue, the most popular anime first, cut into numbered pages.
# It can be narrowed to the anime whose title or studio holds a text.
# A page number that does not exist is brought back to the nearest one that does.
class CatalogueQuery
  PER_PAGE = 12
  FIRST_PAGE = 1
  SORTS = %w[match popularity score recent title].freeze
  TITLE_ORDER = "LOWER(COALESCE(NULLIF(animes.title_english, ''), animes.title_romaji))".freeze

  # The sorts that can be offered: the match needs a scorer.
  def self.sorts(match:) = match ? SORTS : SORTS - [ "match" ]
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

  def initialize(page: FIRST_PAGE, per_page: PER_PAGE, search: nil, filters: CatalogueFilters.from_params(nil), sort: nil, scorer: nil)
    @requested_page = page
    @per_page = per_page
    @search = search.to_s.strip
    @filters = filters
    @sort = sort.to_s
    @scorer = scorer
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
  def ranked_animes = matching_animes.order(*order_clauses)

  attr_reader :filters, :sort, :scorer

  def order_clauses
    case sort
    when "score" then [ column(:average_score).desc.nulls_last, column(:popularity).desc.nulls_last, :id ]
    when "recent" then [ column(:start_date).desc.nulls_last, :id ]
    when "title" then [ Arel.sql(TITLE_ORDER), :id ]
    when "match" then scorer ? [ match_order, :id ] : popularity_clauses
    else popularity_clauses
    end
  end

  def popularity_clauses = [ column(:popularity).desc.nulls_last, :id ]

  def column(name) = Anime.arel_table[name]

  # The scorer ranks the anime in Ruby, then the database gets the ids in that order,
  # so that the page is still cut by the database.
  def match_order
    Arel.sql(Anime.sanitize_sql_array([ "array_position(ARRAY[?]::bigint[], animes.id)", match_ranked_ids ]))
  end

  def match_ranked_ids
    matching_animes.preload(*CARD_ASSOCIATIONS).sort_by { |anime| match_rank_key(anime) }.map(&:id)
  end

  # The closest first, then the most popular (the anime without popularity last), then a stable order.
  def match_rank_key(anime) = [ -scorer.call(anime), -(anime.popularity || -1), anime.id ]

  def matching_animes
    scope = searched_animes
    scope = scope.where(format: filters.formats) if filters.formats.any?
    scope = scope.where(airing_status: filters.statuses) if filters.statuses.any?
    scope = scope.where(season: filters.season) if filters.season
    scope = scope.where(season_year: year_range) if year_range
    scope = scope.where(id: with_every_genre) if filters.genre_ids.any?
    scope
  end

  def year_range
    return if filters.year_from.nil? && filters.year_to.nil?

    filters.year_from..filters.year_to
  end

  def with_every_genre
    AnimeGenre.where(genre_id: filters.genre_ids)
              .group(:anime_id)
              .having("COUNT(*) = ?", filters.genre_ids.size)
              .select(:anime_id)
  end

  def searched_animes
    return Anime.all if search.empty?

    Anime.where(MATCHING_SEARCH, pattern: "%#{Anime.sanitize_sql_like(search)}%")
  end
end
