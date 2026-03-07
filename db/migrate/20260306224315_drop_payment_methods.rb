class DropPaymentMethods < ActiveRecord::Migration[8.1]
  def change
    drop_table :payment_methods do |t|
      t.string :type, null: false
      t.timestamps
    end
  end
end
