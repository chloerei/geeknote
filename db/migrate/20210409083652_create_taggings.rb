class CreateTaggings < ActiveRecord::Migration[6.1]
  def change
    create_table :taggings do |t|
      t.belongs_to :tag, foreign_key: true, index: false
      t.belongs_to :taggable, polymorphic: true

      t.timestamps

      t.index [ :tag_id, :taggable_type, :taggable_id ], name: "index_tag_taggable_uniqueness", unique: true
    end
  end
end
