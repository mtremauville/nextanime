module Organisms
  class ProfileHeaderComponent < ViewComponent::Base
    def initialize(user:)
      @user = user
    end

    private

    attr_reader :user

    def name = user.display_name

    def initial = name.first.upcase

    def member_since = l(user.created_at, format: :month_year)
  end
end
