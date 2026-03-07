class SubscriptionPolicy < ApplicationPolicy
  def index?    = user.admin? || user.customer?
  def show?     = user.admin? || own?
  def create?   = user.admin? || user.customer?
  def cancel?   = user.admin? || own?
  def activate? = user.admin?
  def fail?     = user.admin?
  def retry?    = user.admin?
  def close?    = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all            if user.admin?
      return scope.where(user:)   if user.customer?

      scope.none
    end
  end

  private

  def own?
    record.user == user
  end
end
