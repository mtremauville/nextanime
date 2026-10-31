module Organisms
  # A native modal <dialog> asking the person to confirm a destructive action.
  # The body is the block given to the component.
  class ConfirmationModalComponent < ViewComponent::Base
    def initialize(id:, title:, confirm_label:, confirm_url:, confirm_method: :delete, icon: "exclamation-triangle")
      @modal_id = id
      @title = title
      @confirm_label = confirm_label
      @confirm_url = confirm_url
      @confirm_method = confirm_method
      @icon = icon
      super()
    end

    private

    attr_reader :modal_id, :title, :confirm_label, :confirm_url, :confirm_method, :icon

    def title_id
      "#{modal_id}-title"
    end
  end
end
