module Molecules
  class FormFieldComponent < ViewComponent::Base
    def initialize(name:, label:, type: "text", value: nil, error: nil, hint: nil, **input_attributes)
      @name = name
      @label = label
      @type = type
      @value = value
      @error = error
      @hint = hint
      @input_attributes = input_attributes
      super()
    end

    private

    attr_reader :label, :error, :hint

    def input_id
      "field_#{@name.to_s.parameterize(separator: "_")}"
    end

    def error_id
      "#{input_id}_error"
    end

    def hint_id
      "#{input_id}_hint"
    end

    def describedby
      [ (hint_id if hint), (error_id if error) ].compact.join(" ").presence
    end

    def input_options
      {
        type: @type,
        name: @name,
        id: input_id,
        value: (@value unless @type.to_s == "password"),
        class: class_names("form-control", "is-invalid": error.present?),
        aria: { invalid: (true if error), describedby: describedby }
      }.merge(@input_attributes)
    end
  end
end
