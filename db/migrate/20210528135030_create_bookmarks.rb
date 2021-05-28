class CreateBookmarks < ActiveRecord::Migration[6.1]
  def change
    create_table :bookmarks do |t|
      t.belongs_to :user
      t.belongs_to :post, index: false
      t.integer :status, default: 0

      t.timestamps

      t.index [:post_id, :user_id], unique: true
    end

    add_column :posts, :bookmarks_count, :integer, default: 0
  end
end
