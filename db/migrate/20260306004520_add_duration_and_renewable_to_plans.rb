class AddDurationAndRenewableToPlans < ActiveRecord::Migration[8.1]
  def change
    add_column :plans, :duration_count, :integer
    add_column :plans, :duration_type,  :string
    add_column :plans, :renewable,      :boolean, null: false, default: false
  end
end
