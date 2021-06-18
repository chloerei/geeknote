class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.belongs_to :account
      t.string :title
      t.text :content
      t.text :excerpt
      t.integer :status, default: 0
      t.string :preview_token
      t.datetime :published_at

      t.timestamps

      t.index :published_at
    end
  end
end
