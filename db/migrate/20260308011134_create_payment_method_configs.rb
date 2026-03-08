class CreatePaymentMethodConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_method_configs do |t|
      t.string  :key,     null: false
      t.boolean :enabled, null: false, default: true
      t.timestamps
    end
    add_index :payment_method_configs, :key, unique: true
  end
end
