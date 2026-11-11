module Organisms
  # The side of the watchlist page: how far the member has got overall, and where to resume.
  class WatchlistSummaryComponent < ViewComponent::Base
    def initialize(global_percent:, resume_entry:)
      @global_percent = global_percent
      @resume_entry = resume_entry
      super()
    end

    def render? = global_percent.present? || resume_entry.present?

    private

    attr_reader :global_percent, :resume_entry

    def resume_anime = resume_entry.anime

    def resume_prefix = I18n.t("watchlist_entries.summary.resume_prefix", episode: resume_entry.progress + 1)
  end
end
