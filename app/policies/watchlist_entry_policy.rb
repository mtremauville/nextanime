# Who may use the watchlist: a member, and only for their own entries.
class WatchlistEntryPolicy < ApplicationPolicy
  def create? = owned_by_member?

  private

  def owned_by_member? = user.present? && record.user_id == user.id
end
