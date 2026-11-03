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

    def error_summary
      count = resource.errors.attribute_names.size
      return if count.zero?

      count == 1 ? "1 erreur empêche la création du compte." : "#{count} erreurs empêchent la création du compte."
    end

    def error_for(attribute)
      message = resource.errors[attribute].first
      return message unless attribute == :email && resource.errors.of_kind?(:email, :taken)

      safe_join([ "#{message} ", link_to("Te connecter ?", new_user_session_path, class: "na-auth-form__inline-link") ])
    end

    def privacy_policy_accepted?
      ActiveModel::Type::Boolean.new.cast(resource.privacy_policy) || false
    end
  end
end
