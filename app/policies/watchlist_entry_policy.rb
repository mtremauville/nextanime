# Who may use the watchlist: a member, and only for their own entries.
class WatchlistEntryPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      user ? scope.where(user: user) : scope.none
    end

    private

    attr_reader :user, :scope
  end

  def create? = owned_by_member?

  private

  def owned_by_member? = user.present? && record.user_id == user.id
end
