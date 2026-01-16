class DropAuthorsTable < ActiveRecord::Migration[8.1]
  def up
    drop_table :authors
  end

  def down
    create_table :authors do |t|
      t.belongs_to :post
      t.belongs_to :user
      t.timestamps
      t.index [ :post_id, :user_id ], unique: true
    end
  end
end
