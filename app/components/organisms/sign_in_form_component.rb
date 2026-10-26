module Organisms
  class SignInFormComponent < ViewComponent::Base
    def initialize(resource:)
      @resource = resource
      super()
    end

    private

    attr_reader :resource
  end
end
