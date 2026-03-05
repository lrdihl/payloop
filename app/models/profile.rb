#
# Profile armazena dados pessoais do usuário separados das credenciais.
# Essa separação segue SRP: User cuida de autenticação, Profile cuida de identidade pessoal.
# Permite evoluir regras de perfil sem tocar na lógica de autenticação.
#
class Profile < ApplicationRecord
  belongs_to :user

  validates :full_name, presence: true
  validates :document,  presence: true, uniqueness: true
  # Sem validação de formato aqui — isso é responsabilidade do Contract
end
