class DropCollections < ActiveRecord::Migration[7.1]
  def change
    drop_table :collections
    drop_table :collection_items
  end
end
