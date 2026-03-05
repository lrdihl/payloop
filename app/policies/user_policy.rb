# app/policies/user_policy.rb
#
# Define quem pode fazer o quê com usuários.
#
# Regras:
#   - Admin: acesso total (CRUD em qualquer usuário)
#   - Consumer: pode ver e editar apenas seu próprio perfil
#
# Os métodos retornam booleano puro — sem side effects, sem DB, fácil de testar.
#
class UserPolicy < ApplicationPolicy
  # Listagem de todos os usuários: apenas admins
  def index?
    user.admin?
  end

  # Ver detalhes: admin vê qualquer um, customer só vê a si mesmo
  def show?
    user.admin? || own_record?
  end

  # Criação de usuário via painel admin: só admin
  def create?
    user.admin?
  end

  # Edição: admin edita qualquer um, customer edita apenas o próprio perfil
  def update?
    user.admin? || own_record?
  end

  # Deleção/desativação: apenas admin
  def destroy?
    user.admin?
  end

  # Promover/rebaixar role: apenas admin, e não pode rebaixar a si mesmo
  def update_role?
    user.admin? && !own_record?
  end

  class Scope < ApplicationPolicy::Scope
    # Admin vê todos os usuários; customer só vê a si mesmo
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end

  private

  def own_record?
    record == user
  end
end
