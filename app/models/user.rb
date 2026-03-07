# app/models/user.rb
#
# User é um objeto de infraestrutura — responsável apenas por:
#   - Autenticação via Devise
#   - Persistência (ActiveRecord)
#   - Role enum (identidade de acesso)
#
# IMPORTANTE: Nenhuma regra de negócio vive aqui.
# Casos de uso pertencem aos domain operations em app/domains/identity/operations/
#
class User < ApplicationRecord
  # 1. Modules
  include Pundit::Authorization

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :lockable,
         :trackable

  # 3. Associations
  has_one  :profile,       dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # 4. Field settings
  delegate :full_name, :document, :phone, to: :profile, allow_nil: true

  enum :role, { customer: 0, admin: 1 }, default: :customer

  # 12. Public Instance Methods

  def admin?
    role == "admin"
  end

  def customer?
    role == "customer"
  end
end
