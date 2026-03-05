# spec/models/user_spec.rb
require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe "associations" do
    it { is_expected.to have_one(:profile).dependent(:destroy) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:role).with_values(customer: 0, admin: 1) }
  end

  describe "#admin?" do
    it "retorna true para usuários com role admin" do
      user = build(:user, :admin)
      expect(user.admin?).to be true
    end

    it "retorna false para customers" do
      user = build(:user, :customer)
      expect(user.admin?).to be false
    end
  end

  describe "#customer?" do
    it "retorna true para customers" do
      user = build(:user, :customer)
      expect(user.customer?).to be true
    end
  end

  describe "role padrão" do
    it "cria usuários como customer por padrão" do
      user = create(:user)
      expect(user.role).to eq("customer")
    end
  end

  describe "delegações" do
    let(:user) { create(:user, :with_profile) }

    it "delega full_name para profile" do
      expect(user.full_name).to eq(user.profile.full_name)
    end

    it "retorna nil se não tiver profile" do
      user_sem_profile = create(:user)
      expect(user_sem_profile.full_name).to be_nil
    end
  end
end
