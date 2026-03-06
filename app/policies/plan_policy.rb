class PlanPolicy < ApplicationPolicy
  def index?   = user.admin?
  def show?    = user.admin?
  def create?  = user.admin?
  def update?  = user.admin?
  def destroy? = user.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.admin? ? scope.kept : scope.none
    end
  end
end
