module Molecules
  class AccountActionsComponent < ViewComponent::Base
    def initialize(user: nil)
      @user = user
      super()
    end

    private

    attr_reader :user

    def profile_aria_current = ("page" if helpers.current_page?(profile_path))
  end
end
