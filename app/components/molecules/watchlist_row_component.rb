module Molecules
  # One anime of the watchlist: its poster, its status and how far the member has got.
  class WatchlistRowComponent < ViewComponent::Base
    STATUS_TONES = { "plan_to_watch" => :cyan, "watching" => :magenta, "completed" => :muted }.freeze

    renders_one :actions

    def initialize(entry:)
      @entry = entry
      super()
    end

    private

    attr_reader :entry

    delegate :anime, :percent, to: :entry

    def title = anime.display_title

    def meta = AnimeSummary.new(anime).line

    def status_tone = STATUS_TONES.fetch(entry.status)

    def status_label = I18n.t("watchlist_entries.statuses.#{entry.status}")

    def meter_label = I18n.t("watchlist_entries.row.meter_label", title: title)

    def progress_label
      key = percent ? "progress" : "progress_unknown"
      I18n.t("watchlist_entries.row.#{key}", seen: entry.progress, total: entry.total_episodes)
    end
  end
end
