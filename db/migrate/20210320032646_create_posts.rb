class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.belongs_to :space
      t.belongs_to :author
      t.string :title
      t.text :content
      t.text :summary
      t.integer :status, default: 0
      t.string :preview_token

      t.timestamps
    end
  end
end
