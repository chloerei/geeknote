class CreateCollectionItems < ActiveRecord::Migration[6.1]
  def change
    create_table :collection_items do |t|
      t.belongs_to :collection, index: false
      t.belongs_to :post

      t.timestamps

      t.index [:collection_id, :post_id], unique: true
    end

    add_column :collections, :posts_count, :integer, default: 0
    add_column :posts, :collections_count, :integer, default: 0
  end
end
