module Organisms
  class ResetPasswordFormComponent < ViewComponent::Base
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
      resource.errors[attribute].to_sentence.presence
    end

    def token_error
      resource.errors.full_messages_for(:reset_password_token).to_sentence.presence
    end
  end
end
