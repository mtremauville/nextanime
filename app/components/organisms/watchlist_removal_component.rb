module Organisms
  # The button of a watchlist row that asks for a confirmation before removing the entry.
  class WatchlistRemovalComponent < ViewComponent::Base
    def initialize(entry:, status: nil)
      @entry = entry
      @status = status
      super()
    end

    private

    attr_reader :entry, :status

    def modal_id = "remove-entry-#{entry.id}"

    def confirm_url = watchlist_entry_path(entry, status: status)

    def title = translate(:title, title: entry.anime.display_title)

    def warning = [ progress_lost, translate(:come_back) ].compact.join(" ")

    # Nothing is lost when no episode has been watched yet.
    def progress_lost
      return if entry.progress.zero?
      return translate(:progress_lost_unknown, seen: entry.progress) unless total_known?

      translate(:progress_lost, seen: entry.progress, total: entry.total_episodes)
    end

    def total_known? = entry.percent.present?

    def translate(key, **values) = I18n.t("watchlist_entries.removal.#{key}", **values)
  end
end
