class RecreatePostRevisions < ActiveRecord::Migration[8.1]
  def change
    create_table :post_revisions do |t|
      t.belongs_to :post, null: false
      t.belongs_to :user

      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
