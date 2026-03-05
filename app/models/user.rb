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
  include Pundit::Authorization

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :lockable,
         :trackable

  enum :role, { customer: 0, admin: 1 }, default: :customer

  has_one :profile, dependent: :destroy

  # Delegações para evitar Law of Demeter nos controllers/views
  delegate :full_name, :document, :phone, to: :profile, allow_nil: true

  # Guard semântico — evita `user.role == "admin"` espalhado no código
  def admin?
    role == "admin"
  end

  def customer?
    role == "customer"
  end
end
