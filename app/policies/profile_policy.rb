# app/policies/profile_policy.rb
#
# Política para o recurso Profile.
# Profile é sempre acessado via User — a política reflete isso.
#
class ProfilePolicy < ApplicationPolicy
  # Admin pode listar todos os perfis
  def index?
    user.admin?
  end

  # Admin vê qualquer perfil; consumer vê apenas o seu
  def show?
    user.admin? || own_profile?
  end

  # Admin edita qualquer perfil; consumer edita apenas o seu
  def update?
    user.admin? || own_profile?
  end

  # Apenas admin pode deletar perfis (raro, mas previsto)
  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  private

  def own_profile?
    record.user_id == user.id
  end
end
