class AddPaymentMethodToSubscriptions < ActiveRecord::Migration[8.1]
  def change
    add_column :subscriptions, :payment_method, :string
  end
end
