class CreateWebhookTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_tokens do |t|
      t.string :webhook
      t.string :token
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :webhook_tokens, :token, unique: true
    add_index :webhook_tokens, [ :webhook, :token ]
  end
end
