module Organisms
  class AccountFormComponent < ViewComponent::Base
    def initialize(resource:)
      @resource = resource
      super()
    end

    private

    attr_reader :resource

    def password_hint
      "#{Devise.password_length.min} caractères minimum."
    end

    def error_summary
      count = resource.errors.attribute_names.size
      return if count.zero?

      count == 1 ? "1 erreur empêche l'enregistrement." : "#{count} erreurs empêchent l'enregistrement."
    end

    def error_for(attribute)
      resource.errors[attribute].first
    end
  end
end
