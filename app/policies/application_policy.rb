# app/policies/application_policy.rb
# Política base do Pundit.
# Por padrão, NADA é permitido — toda permissão é opt-in explícito nas subclasses.
# Isso segue o princípio de menor privilégio: melhor negar tudo e liberar o necessário
# do que liberar tudo e tentar bloquear o que não deve.
#
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "usuário não autenticado" unless user

    @user   = user
    @record = record
  end

  def index?   = false
  def show?    = false
  def create?  = false
  def new?     = create?
  def update?  = false
  def edit?    = update?
  def destroy? = false

  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "#{self.class}#resolve não implementado"
    end

    private

    attr_reader :user, :scope
  end
end
