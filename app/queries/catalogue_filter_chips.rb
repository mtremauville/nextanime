# The filters under way, as one chip per selected value. Each chip holds its label and the
# filters that remain once it is removed, so that the page can link it to the catalogue without it.
class CatalogueFilterChips
  Chip = Data.define(:label, :remaining)

  def initialize(filters:, genres:, studios:)
    @filters = filters
    @genres = genres
    @studios = studios
  end

  def call
    listed_chips(:genre_ids, genres) +
      listed_chips(:studio_ids, studios) +
      named_chips(:formats, "animes.formats") +
      season_chips +
      years_chips +
      named_chips(:statuses, "catalogue.filters.statuses")
  end

  private

  attr_reader :filters, :genres, :studios

  # A genre or a studio the catalogue does not list has no name to show, so it gets no chip.
  def listed_chips(name, items)
    by_id = items.index_by(&:id)

    filters.public_send(name).filter_map do |id|
      item = by_id[id]
      chip(item.name, name, id) if item
    end
  end

  def named_chips(name, scope)
    filters.public_send(name).map { |key| chip(I18n.t("#{scope}.#{key}"), name, key) }
  end

  def season_chips
    return [] unless filters.season

    [ chip(I18n.t("animes.seasons.#{filters.season}"), :season) ]
  end

  def years_chips
    label = years_label
    label ? [ chip(label, :years) ] : []
  end

  def years_label
    from = filters.year_from
    to = filters.year_to

    if from && to then year_text(:range, from: from, to: to)
    elsif from then year_text(:from, year: from)
    elsif to then year_text(:to, year: to)
    end
  end

  def year_text(key, **values) = I18n.t("catalogue.active_filters.years.#{key}", **values)

  def chip(label, name, value = nil)
    Chip.new(label: label, remaining: filters.without(name, value))
  end
end
