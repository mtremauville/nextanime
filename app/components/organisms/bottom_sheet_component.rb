module Organisms
  # A sheet that rises from the bottom of the screen. It is a native <dialog>, so the browser traps
  # the focus, closes it on Escape and gives the focus back to what opened it. The content is the
  # block given to the component; the trigger slot holds what opens the sheet.
  class BottomSheetComponent < ViewComponent::Base
    renders_one :trigger

    def initialize(id:, title:, close_label:)
      @sheet_id = id
      @title = title
      @close_label = close_label
      super()
    end

    private

    attr_reader :sheet_id, :title, :close_label

    def title_id = "#{sheet_id}-title"
  end
end
