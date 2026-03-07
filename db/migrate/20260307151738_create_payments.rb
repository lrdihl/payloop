class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :subscription, null: false, foreign_key: true
      t.integer :amount_cents
      t.string :currency
      t.string :payment_method
      t.string :status
      t.string :transaction_id
      t.text :gateway_response
      t.integer :attempt_number

      t.timestamps
    end

    add_index :payments, :status
    add_index :payments, [ :subscription_id, :attempt_number ]
  end
end
