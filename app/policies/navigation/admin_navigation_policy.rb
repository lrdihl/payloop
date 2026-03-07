module Navigation
  class AdminNavigationPolicy < ApplicationPolicy
    def users?         = user.admin?
    def plans?         = user.admin?
    def subscriptions? = user.admin?
  end
end
