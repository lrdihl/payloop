# spec/domains/identity/operations/update_profile_spec.rb
require "rails_helper"

RSpec.describe Identity::Operations::UpdateProfile do
  subject(:operation) { described_class.new }

  let(:user)    { create(:user, :with_profile) }
  let(:profile) { user.profile }

  let(:valid_attrs) do
    { full_name: "Nome Atualizado", document: profile.document, phone: "47911112222" }
  end

  describe "com dados válidos" do
    it "retorna Success com o profile atualizado" do
      result = operation.call(profile:, attributes: valid_attrs)

      expect(result).to be_success
      expect(result.value!.full_name).to eq("Nome Atualizado")
    end

    it "persiste a alteração no banco" do
      operation.call(profile:, attributes: valid_attrs)
      expect(profile.reload.full_name).to eq("Nome Atualizado")
    end
  end

  describe "com dados inválidos" do
    it "retorna Failure com tipo :validation para nome muito curto" do
      result = operation.call(profile:, attributes: valid_attrs.merge(full_name: "AB"))

      expect(result).to be_failure
      expect(result.failure[:type]).to eq(:validation)
    end

    it "não altera o banco quando a validação falha" do
      original_name = profile.full_name
      operation.call(profile:, attributes: valid_attrs.merge(full_name: "X"))

      expect(profile.reload.full_name).to eq(original_name)
    end
  end
end
