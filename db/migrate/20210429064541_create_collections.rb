class CreateCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :collections do |t|
      t.belongs_to :account
      t.string :name
      t.text :description
      t.integer :visibility, default: 0
      t.integer :posts_count, default: 0

      t.timestamps
    end
  end
end
