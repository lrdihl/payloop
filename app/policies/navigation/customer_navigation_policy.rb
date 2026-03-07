module Navigation
  class CustomerNavigationPolicy < ApplicationPolicy
    def subscriptions? = user.customer?
    def profile?       = user.customer?
  end
end
