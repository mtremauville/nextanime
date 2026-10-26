module Organisms
  class SignUpFormComponent < ViewComponent::Base
    PRIVACY_LABEL = "J'accepte la politique de confidentialité. Je peux exporter ou supprimer mes données à tout moment.".freeze

    def initialize(resource:)
      @resource = resource
      super()
    end

    private

    attr_reader :resource

    def password_hint
      "#{Devise.password_length.min} caractères minimum."
    end

    def error_for(attribute)
      resource.errors[attribute].first
    end

    def privacy_policy_accepted?
      ActiveModel::Type::Boolean.new.cast(resource.privacy_policy) || false
    end
  end
end
