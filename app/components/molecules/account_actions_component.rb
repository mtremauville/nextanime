module Molecules
  class AccountActionsComponent < ViewComponent::Base
    def initialize(user: nil)
      @user = user
      super()
    end

    private

    attr_reader :user
  end
end
