module Organisms
  class SignInFormComponent < ViewComponent::Base
    def initialize(resource:, failed: false)
      @resource = resource
      @failed = failed
      super()
    end

    private

    attr_reader :resource, :failed
  end
end
