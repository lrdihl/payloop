# Guardfile
#
# Fecha o loop de feedback do TDD automaticamente.
# Ao salvar qualquer arquivo, Guard executa apenas os specs relacionados.
#
# Instalar: bundle exec guard (em terminal separado durante desenvolvimento)
#

# ── Opções globais ────────────────────────────────────────────────────────────
clearing :on  # Limpa o terminal a cada execução

notification :off

# ── RSpec ─────────────────────────────────────────────────────────────────────
guard :rspec, cmd: "bundle exec rspec --format progress --color --no-profile" do

  # Roda tudo quando o spec_helper ou rails_helper muda
  watch("spec/spec_helper.rb")   { "spec" }
  watch("spec/rails_helper.rb")  { "spec" }

  # Qualquer spec muda → roda ele mesmo
  watch(%r{^spec/.+_spec\.rb$})

  # ── Domínios ────────────────────────────────────────────────────────────────

  # Contract mudou → roda spec do contract
  watch(%r{^app/domains/(.+)/contracts/(.+)\.rb$}) do |m|
    "spec/domains/#{m[1]}/contracts/#{m[2]}_spec.rb"
  end

  # Operation mudou → roda spec da operation
  watch(%r{^app/domains/(.+)/operations/(.+)\.rb$}) do |m|
    "spec/domains/#{m[1]}/operations/#{m[2]}_spec.rb"
  end

  # Service de domínio mudou → roda spec do service
  watch(%r{^app/domains/(.+)/services/(.+)\.rb$}) do |m|
    "spec/domains/#{m[1]}/services/#{m[2]}_spec.rb"
  end

  # ── Camada Rails ─────────────────────────────────────────────────────────────

  # Model mudou → roda spec do model
  watch(%r{^app/models/(.+)\.rb$}) do |m|
    "spec/models/#{m[1]}_spec.rb"
  end

  # Policy mudou → roda spec da policy
  watch(%r{^app/policies/(.+)\.rb$}) do |m|
    "spec/policies/#{m[1]}_spec.rb"
  end

  # Controller mudou → roda request spec
  watch(%r{^app/controllers/(.+)_controller\.rb$}) do |m|
    "spec/requests/#{m[1]}_spec.rb"
  end

  # Controller de namespace (admin/, consumer/) → roda request spec do namespace
  watch(%r{^app/controllers/(.+)/(.+)_controller\.rb$}) do |m|
    "spec/requests/#{m[1]}/#{m[2]}_spec.rb"
  end

  # ApplicationController mudou → roda todos os request specs
  watch("app/controllers/application_controller.rb") { "spec/requests" }

  # ApplicationPolicy mudou → roda todas as policy specs
  watch("app/policies/application_policy.rb") { "spec/policies" }

  # ── Suporte e factories ───────────────────────────────────────────────────────

  # Factory mudou → roda spec do model correspondente
  watch(%r{^spec/factories/(.+)\.rb$}) do |m|
    "spec/models/#{m[1].singularize}_spec.rb"
  end

  # Shared examples mudaram → roda tudo (são usados em múltiplos specs)
  watch(%r{^spec/support/shared_examples/.+\.rb$}) { "spec" }

  # Support helpers mudaram → roda tudo
  watch(%r{^spec/support/.+\.rb$}) { "spec" }

  # ── Rotas ────────────────────────────────────────────────────────────────────

  watch("config/routes.rb") { "spec/requests" }

  # ── Initializers ─────────────────────────────────────────────────────────────

  watch(%r{^config/initializers/(.+)\.rb$}) { "spec" }
end
