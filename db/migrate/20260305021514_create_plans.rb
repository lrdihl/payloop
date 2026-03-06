class CreatePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :plans do |t|
      t.string   :name,           null: false
      t.text     :description
      t.integer  :price_cents,    null: false
      t.string   :currency,       null: false, default: "BRL"
      t.integer  :interval_count, null: false, default: 1
      t.string   :interval_type,  null: false, default: "month"
      t.boolean  :active,         null: false, default: true
      t.datetime :discarded_at

      t.timestamps
    end

    add_index :plans, :discarded_at
  end
end
