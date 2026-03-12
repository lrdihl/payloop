class AddLockVersionToSubscriptionsAndPayments < ActiveRecord::Migration[8.1]
  def change
    add_column :subscriptions, :lock_version, :integer, default: 0, null: false
    add_column :payments,      :lock_version, :integer, default: 0, null: false
  end
end
