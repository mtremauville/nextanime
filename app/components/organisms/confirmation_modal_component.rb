module Organisms
  # A native modal <dialog> asking the person to confirm a destructive action.
  # The body is the block given to the component.
  class ConfirmationModalComponent < ViewComponent::Base
    TONES = %i[magenta cyan].freeze

    def initialize(id:, title:, confirm_label:, confirm_url:, confirm_method: :delete, icon: "exclamation-triangle",
                   tone: :magenta, trigger_label: nil, trigger_variant: :outline, confirmation_word: nil)
      raise ArgumentError, "Unknown tone: #{tone.inspect}" unless TONES.include?(tone)

      @modal_id = id
      @title = title
      @confirm_label = confirm_label
      @confirm_url = confirm_url
      @confirm_method = confirm_method
      @icon = icon
      @tone = tone
      @trigger_label = trigger_label
      @trigger_variant = trigger_variant
      @confirmation_word = confirmation_word
      super()
    end

    private

    attr_reader :modal_id, :title, :confirm_label, :confirm_url, :confirm_method, :icon, :tone,
                :trigger_label, :trigger_variant, :confirmation_word

    def title_id
      "#{modal_id}-title"
    end

    def word_input_id
      "#{modal_id}-confirm"
    end

    def controller_data
      { controller: "confirm-modal", confirm_modal_word_value: confirmation_word }.compact
    end

    # With a word to type, the confirmation stays disabled until the controller sees it.
    def confirm_attributes
      return {} unless confirmation_word

      { disabled: true, aria: { disabled: true }, data: { confirm_modal_target: "confirm" } }
    end
  end
end
