class SubscriptionPolicy < ApplicationPolicy
  def index?    = user.admin?
  def show?     = user.admin?
  def create?   = user.admin?
  def activate? = user.admin?
  def fail?     = user.admin?
  def retry?    = user.admin?
  def cancel?   = user.admin?
  def close?    = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all  if user.admin?
      return scope.none if user.customer?

      scope.none
    end
  end
end
