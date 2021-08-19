class CreateCollectionItems < ActiveRecord::Migration[6.1]
  def change
    create_table :collection_items do |t|
      t.belongs_to :collection
      t.belongs_to :post, index: false
      t.integer :position

      t.timestamps

      t.index [:post_id, :collection_id], unique: true
    end
  end
end
