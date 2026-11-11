# What the watchlist page shows around the list itself: the counters per
# status, the overall progress and the entry to resume.
class WatchlistOverview
  PERCENT = 100.0

  def initialize(entries)
    @entries = entries
  end

  def counts
    grouped = entries.group(:status).count
    WatchlistEntry.statuses.keys.index_with { |status| grouped.fetch(status, 0) }
  end

  def total = counts.values.sum

  # Entries whose episode count is unknown (anime still airing) are left out.
  def global_percent
    known = progress_rows.select { |_progress, episodes| episodes.to_i.positive? }
    return if known.empty?

    watched = known.sum { |progress, episodes| [ progress, episodes ].min }
    (watched * PERCENT / known.sum { |_progress, episodes| episodes }).round
  end

  def resume_entry = entries.watching.includes(:anime).order(updated_at: :desc).first

  private

  attr_reader :entries

  def progress_rows = entries.joins(:anime).pluck(:progress, "animes.episodes")
end
