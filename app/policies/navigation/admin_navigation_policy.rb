module Navigation
  class AdminNavigationPolicy < ApplicationPolicy
    def users?                  = user.admin?
    def plans?                  = user.admin?
    def subscriptions?          = user.admin?
    def payment_method_configs? = user.admin?
  end
end
