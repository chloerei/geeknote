class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.belongs_to :user, null: false
      t.belongs_to :likable, null: false, polymorphic: true, index: false

      t.timestamps

      t.index [:likable_type, :likable_id, :user_id], unique: true
    end
  end
end
