module Molecules
  class CheckboxFieldComponent < ViewComponent::Base
    def initialize(name:, label:, checked: false, error: nil, **input_attributes)
      @name = name
      @label = label
      @checked = checked
      @error = error
      @input_attributes = input_attributes
      super()
    end

    private

    attr_reader :name, :label, :error

    def input_id
      "field_#{name.to_s.parameterize(separator: "_")}"
    end

    def error_id
      "#{input_id}_error"
    end

    def input_options
      {
        type: "checkbox",
        name: name,
        id: input_id,
        value: "1",
        checked: @checked,
        class: class_names("form-check-input", "is-invalid": error.present?),
        aria: { invalid: (true if error), describedby: (error_id if error) }
      }.merge(@input_attributes)
    end
  end
end
