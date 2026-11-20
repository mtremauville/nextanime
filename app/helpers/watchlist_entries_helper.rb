module WatchlistEntriesHelper
  # The links of the filter by status: everything, then one per status with its number of entries.
  def watchlist_filter_choices(overview, current_status)
    everything = { label: t("watchlist_entries.index.filter.all", number: overview.total), href: watchlist_path, current: current_status.nil? }
    by_status = overview.counts.map do |status, number|
      { label: t("watchlist_entries.index.filter.#{status}", number: number), href: watchlist_path(status: status), current: current_status == status }
    end
    [ everything, *by_status ]
  end
end
