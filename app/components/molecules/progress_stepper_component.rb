module Molecules
  # The two buttons that move the progress of a watchlist entry one episode back or forward.
  # A button that would change nothing is disabled.
  class ProgressStepperComponent < ViewComponent::Base
    def initialize(entry:, status: nil)
      @entry = entry
      @status = status
      super()
    end

    private

    attr_reader :entry, :status

    def path = watchlist_entry_path(entry, status: status)

    def label_for(move) = I18n.t("watchlist_entries.stepper.#{move}", title: entry.anime.display_title)

    def rewind_disabled? = entry.progress.zero?

    def advance_disabled? = entry.fully_watched?
  end
end
