class CreateAuthors < ActiveRecord::Migration[6.1]
  def change
    create_table :authors do |t|
      t.belongs_to :post
      t.belongs_to :user

      t.timestamps

      t.index [ :post_id, :user_id ], unique: true
    end
  end
end
