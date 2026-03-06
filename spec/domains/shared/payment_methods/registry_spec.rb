require "rails_helper"

RSpec.describe SharedPaymentMethods::Registry do
  # Isola o Registry entre testes usando uma cópia limpa
  around do |example|
    original = described_class.instance_variable_get(:@methods).dup
    example.run
    described_class.instance_variable_set(:@methods, original)
  end

  describe ".register e .find" do
    let(:dummy_class) { Class.new }

    before { described_class.register(:dummy, dummy_class) }

    it "encontra a classe registrada pela chave" do
      expect(described_class.find(:dummy)).to eq(dummy_class)
    end

    it "aceita chave como string ou symbol" do
      expect(described_class.find("dummy")).to eq(dummy_class)
    end
  end

  describe ".all" do
    let(:dummy_class) { Class.new }

    before { described_class.register(:dummy, dummy_class) }

    it "retorna hash com todos os métodos registrados" do
      expect(described_class.all).to include(dummy: dummy_class)
    end
  end

  describe ".find com chave desconhecida" do
    it "levanta KeyError" do
      expect { described_class.find(:inexistente) }.to raise_error(KeyError)
    end
  end
end
