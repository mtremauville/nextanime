# The studios offered by the catalogue filter, each with its number of anime: the most
# prolific ones, plus the ones already selected so that they can always be unchecked.
class CatalogueStudios
  DEFAULT_LIMIT = 200

  Option = Data.define(:id, :name, :count)

  def initialize(selected_ids: [], limit: DEFAULT_LIMIT)
    @selected_ids = selected_ids
    @limit = limit
  end

  def call
    (prolific + selected).uniq(&:id).sort_by { |option| [ -option.count, option.name.downcase ] }
  end

  private

  attr_reader :selected_ids, :limit

  def prolific = options(ranked.limit(limit))

  def selected = options(ranked.where(id: selected_ids))

  # Only the studios with at least one anime, whether it is their main one or not.
  def ranked
    Studio.joins(:anime_studios)
          .group("studios.id")
          .select("studios.id, studios.name, COUNT(anime_studios.id) AS animes_count")
          .order(Arel.sql("animes_count DESC, LOWER(studios.name)"))
  end

  def options(relation)
    relation.map { |studio| Option.new(id: studio.id, name: studio.name, count: studio.animes_count) }
  end
end
