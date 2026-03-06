require "rails_helper"

RSpec.describe Shared::PaymentMethods::Registry do
  around do |example|
    original_methods = described_class.instance_variable_get(:@methods).dup
    original_status = described_class.instance_variable_get(:@status).dup
    described_class.instance_variable_set(:@methods, {})
    described_class.instance_variable_set(:@status, {})
    example.run
    described_class.instance_variable_set(:@methods, original_methods)
    described_class.instance_variable_set(:@status, original_status)
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

    it "registra como ativo por padrão" do
      expect(described_class.active?(:dummy)).to be true
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

  describe ".disable e .enable" do
    let(:dummy_class) { Class.new }

    before { described_class.register(:dummy, dummy_class) }

    it "disable marca como inativo" do
      described_class.disable(:dummy)
      expect(described_class.active?(:dummy)).to be false
    end

    it "enable reativa um método desativado" do
      described_class.disable(:dummy)
      described_class.enable(:dummy)
      expect(described_class.active?(:dummy)).to be true
    end

    it "find ainda resolve classe mesmo quando inativo" do
      described_class.disable(:dummy)
      expect(described_class.find(:dummy)).to eq(dummy_class)
    end
  end

  describe ".active_methods" do
    let(:dummy_a) { Class.new }
    let(:dummy_b) { Class.new }

    before do
      described_class.register(:a, dummy_a)
      described_class.register(:b, dummy_b)
    end

    it "retorna apenas os métodos ativos" do
      described_class.disable(:b)
      expect(described_class.active_methods).to eq(a: dummy_a)
    end
  end
end
