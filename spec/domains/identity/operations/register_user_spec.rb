require "rails_helper"

RSpec.describe Identity::Operations::RegisterUser do
# ─── Falha no step :validate ────────────────────────────────────────────────

  describe "com dados inválidos" do
    it "retorna Failure com tipo :validation" do
      result = operation.call(valid_params.merge(email: "nao-é-email"))

      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
      expect(result.failure[:errors][:email]).not_to be_empty
    end

    it "não cria User quando a validação falha" do
      operation.call(valid_params.merge(password: "123"))
      expect(User.find_by(email: valid_params[:email])).to be_nil
    end
  end
end