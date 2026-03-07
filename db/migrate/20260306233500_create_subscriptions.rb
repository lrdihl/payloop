class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.string  :status,        null: false, default: "pending_payment"
      t.date    :joined_at,     null: false
      t.date    :closed_at
      t.date    :canceled_at
      t.date    :next_due_date, null: false
      t.timestamps

      t.index [ :user_id, :plan_id, :status ]
      t.index :status
      t.index :next_due_date
      t.index :closed_at
    end
  end
end
