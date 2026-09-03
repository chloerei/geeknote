class CreateAIChats < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_chats do |t|
      t.references :post, null: false
      t.references :user, null: false
      t.references :ruby_llm_model, null: false, foreign_key: { to_table: :ruby_llm_models }, type: :bigint
      t.boolean :cancelled, null: false, default: false
      t.jsonb :snapshot, null: false, default: {}
      t.timestamps
    end
  end
end
