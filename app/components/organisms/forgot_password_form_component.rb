module Organisms
  class ForgotPasswordFormComponent < ViewComponent::Base
    def initialize(resource:)
      @resource = resource
      super()
    end

    private

    attr_reader :resource
  end
end
