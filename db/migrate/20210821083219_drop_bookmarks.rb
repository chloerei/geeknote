class DropBookmarks < ActiveRecord::Migration[6.1]
  def change
    drop_table :bookmarks do |t|
      t.belongs_to :user
      t.belongs_to :post, index: false
      t.integer :status, default: 0

      t.timestamps

      t.index [ :post_id, :user_id ], unique: true
    end

    remove_column :posts, :bookmarks_count, :integer, default: 0
  end
end
