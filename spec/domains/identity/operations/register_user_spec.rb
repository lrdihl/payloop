require "rails_helper"

RSpec.describe Identity::Operations::RegisterUser do
  subject(:operation) { described_class.new }

  let(:valid_params) do
    {
      email:                 "novo@exemplo.com",
      password:              "senha@123",
      password_confirmation: "senha@123",
      full_name:             "Maria Oliveira",
      document:              "98765432100",
      phone:                 "47988887777"
    }
  end

  # ─── Falha no step :validate ────────────────────────────────────────────────
  describe "com dados inválidos" do
    it "retorna Failure com tipo :validation" do
      result = operation.call(valid_params.merge(email: "nao-é-email"))

      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
      expect(result.failure[:errors][:email]).not_to be_empty
    end
  end
end
