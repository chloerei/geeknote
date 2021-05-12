class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.belongs_to :account
      t.belongs_to :commentable, polymorphic: true
      t.belongs_to :user
      t.belongs_to :parent
      t.text :content
      t.integer :likes_count, default: 0
      t.integer :replies_count, default: 0

      t.timestamps
    end
  end
end
