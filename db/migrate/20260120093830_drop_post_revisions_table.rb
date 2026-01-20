class DropPostRevisionsTable < ActiveRecord::Migration[8.1]
  def up
    drop_table :post_revisions
  end

  def down
    create_table :post_revisions do |t|
      t.belongs_to :post
      t.belongs_to :user
      t.string :name
      t.integer :status, default: 0
      t.string :title
      t.text :content
      t.timestamps
    end
  end
end
