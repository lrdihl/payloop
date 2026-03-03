# db/migrate/20240101000002_create_profiles.rb
class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.string :full_name, null: false
      t.string :document,  null: false  # CPF ou CNPJ
      t.string :phone

      t.timestamps
    end

    add_index :profiles, :document, unique: true
  end
end
