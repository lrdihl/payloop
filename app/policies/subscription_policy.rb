class SubscriptionPolicy < ApplicationPolicy
  NON_TERMINAL_STATUSES = %w[pending_payment error_payment active].freeze

  def index?                  = user.admin? || user.customer?
  def show?                   = user.admin? || own?
  def create?                 = user.admin? || user.customer?
  def cancel?                 = user.admin? || own?
  def activate?               = user.admin?
  def fail?                   = user.admin?
  def retry?                   = user.admin?
  def close?                  = user.admin?
  def update_payment_method?  = non_terminal? && (user.admin? || own?)
  def charge?                 = user.admin?

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

  def non_terminal?
    NON_TERMINAL_STATUSES.include?(record.status)
  end
end
