class CreateCollectionItems < ActiveRecord::Migration[6.1]
  def change
    create_table :collection_items do |t|
      t.belongs_to :collection
      t.belongs_to :post
      t.integer :position

      t.timestamps
    end
  end
end
