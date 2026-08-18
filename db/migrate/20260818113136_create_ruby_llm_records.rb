class CreateRubyLlmRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :ruby_llm_models do |t|
      t.string :model_id, null: false
      t.string :name, null: false
      t.string :provider, null: false
      t.string :family
      t.datetime :model_created_at
      t.integer :context_window
      t.integer :max_output_tokens
      t.date :knowledge_cutoff

      t.jsonb :modalities, default: {}
      t.jsonb :capabilities, default: []
      t.jsonb :pricing, default: {}
      t.jsonb :metadata, default: {}

      t.timestamps

      t.index [ :provider, :model_id ], unique: true
      t.index :provider
      t.index :family
      t.index :capabilities, using: :gin
      t.index :modalities, using: :gin
    end

    create_table :ruby_llm_tool_calls do |t|
      t.references :message, polymorphic: true, null: false, type: :bigint, index: false
      t.references :result, polymorphic: true, type: :bigint, index: false
      t.string :tool_call_id, null: false
      t.string :name, null: false
      t.text :thought_signature
      t.string :approval

      t.jsonb :arguments, default: {}

      t.timestamps

      t.index [ :message_type, :message_id ]
      t.index [ :result_type, :result_id ]
      t.index :tool_call_id, unique: true
      t.index :name
    end

    create_table :ruby_llm_usages do |t|
      t.references :chat, polymorphic: true, null: false, type: :bigint, index: false
      t.references :message, polymorphic: true, type: :bigint, index: false
      t.string :operation, null: false
      t.string :provider, null: false
      t.string :model, null: false
      t.string :status, null: false
      t.integer :input_tokens
      t.integer :output_tokens
      t.integer :cache_read_tokens
      t.integer :cache_write_tokens
      t.integer :thinking_tokens
      t.decimal :input_cost, precision: 16, scale: 10
      t.decimal :output_cost, precision: 16, scale: 10
      t.decimal :cache_read_cost, precision: 16, scale: 10
      t.decimal :cache_write_cost, precision: 16, scale: 10
      t.decimal :thinking_cost, precision: 16, scale: 10
      t.decimal :total_cost, precision: 16, scale: 10
      t.timestamps

      t.index [ :chat_type, :chat_id ]
      t.index [ :message_type, :message_id ]
      t.index :status
      t.check_constraint "operation IN ('chat', 'embedding', 'moderation', 'image', 'speech', 'transcription', 'ocr', 'rerank')"
      t.check_constraint "status IN ('pending', 'succeeded', 'failed', 'cancelled')"
    end

    create_table :ruby_llm_batches do |t|
      t.string :provider_batch_id, null: false
      t.string :provider, null: false
      t.string :status
      t.boolean :completed, null: false, default: false
      t.string :chat_type
      t.string :batch_protocol

      t.json :chat_ids, default: []

      t.json :request_counts
      t.timestamps

      t.index [ :provider, :provider_batch_id ], unique: true
      t.index :status
    end
  end
end
