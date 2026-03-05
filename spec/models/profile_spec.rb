# spec/models/profile_spec.rb
require "rails_helper"

RSpec.describe Profile, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { create(:profile) }

    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:document) }
    it { is_expected.to validate_uniqueness_of(:document).case_insensitive }
  end
end
