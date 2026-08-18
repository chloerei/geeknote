class CreateAIChats < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_chats do |t|
      t.references :ruby_llm_model, null: false, foreign_key: { to_table: :ruby_llm_models }, type: :bigint
      t.boolean :cancelled, null: false, default: false
      t.timestamps
    end
  end
end
