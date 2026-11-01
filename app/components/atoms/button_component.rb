module Atoms
  class ButtonComponent < ViewComponent::Base
    VARIANTS = {
      primary: "btn btn-na-primary",
      outline: "btn btn-na-outline",
      ghost: "btn btn-na-ghost"
    }.freeze

    def initialize(variant: :primary, type: "button", href: nil, **attributes)
      raise ArgumentError, "Unknown variant: #{variant.inspect}" unless VARIANTS.key?(variant)

      @type = type
      @href = href
      @css_class = class_names(VARIANTS.fetch(variant), attributes.delete(:class))
      @attributes = attributes
      super()
    end

    def call
      if @href
        link_to(content, @href, class: @css_class, **@attributes)
      else
        button_tag(content, type: @type, class: @css_class, **@attributes)
      end
    end
  end
end
