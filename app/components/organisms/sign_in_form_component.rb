module Organisms
  class SignInFormComponent < ViewComponent::Base
    def initialize(resource:, failed: false, forgot_password_href: nil)
      @resource = resource
      @failed = failed
      @forgot_password_href = forgot_password_href
      super()
    end

    private

    attr_reader :resource, :failed, :forgot_password_href
  end
end
