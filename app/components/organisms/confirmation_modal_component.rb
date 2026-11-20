module Organisms
  # A native modal <dialog> asking the person to confirm a destructive action.
  # The body is the block given to the component.
  # The trigger shows a label, an icon, or both; an icon alone needs an aria label.
  class ConfirmationModalComponent < ViewComponent::Base
    TONES = %i[magenta cyan].freeze

    def initialize(id:, title:, confirm_label:, confirm_url:, confirm_method: :delete, icon: "exclamation-triangle",
                   tone: :magenta, trigger_label: nil, trigger_variant: :outline, trigger_icon: nil,
                   trigger_aria_label: nil, confirmation_word: nil)
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
      @trigger_icon = trigger_icon
      @trigger_aria_label = trigger_aria_label
      @confirmation_word = confirmation_word
      super()
    end

    private

    attr_reader :modal_id, :title, :confirm_label, :confirm_url, :confirm_method, :icon, :tone,
                :trigger_label, :trigger_variant, :trigger_icon, :trigger_aria_label, :confirmation_word

    def title_id
      "#{modal_id}-title"
    end

    def word_input_id
      "#{modal_id}-confirm"
    end

    def controller_data
      { controller: "confirm-modal", confirm_modal_word_value: confirmation_word }.compact
    end

    def trigger_aria_attributes
      { label: trigger_aria_label }.compact
    end

    # With a word to type, the confirmation stays disabled until the controller sees it.
    def confirm_attributes
      return {} unless confirmation_word

      { disabled: true, aria: { disabled: true }, data: { confirm_modal_target: "confirm" } }
    end
  end
end
